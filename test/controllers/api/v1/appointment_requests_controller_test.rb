require "test_helper"

module Api
  module V1
    class AppointmentRequestsControllerTest < ActionDispatch::IntegrationTest
      def setup
        @nutritionist = Nutritionist.create!(name: "Dra. Ana Silva", location: "Porto")
        @service = @nutritionist.services.create!(name: "Consulta Geral", price: 50)

        @appointment_request = AppointmentRequest.create!(
          nutritionist: @nutritionist,
          service: @service,
          guest_name: "João Silva",
          guest_email: "joao@example.com",
          desired_date: Date.tomorrow,
          desired_time: Time.zone.parse("10:00"),
          status: "pending"
        )
      end

      # Accept endpoint tests
      test "should accept appointment request" do
        patch accept_api_v1_appointment_request_path(@appointment_request), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        assert_equal true, json["success"]
        assert_equal "Appointment request accepted successfully", json["message"]

        # Check status changed
        @appointment_request.reload
        assert_equal "accepted", @appointment_request.status
      end

      test "should return appointment data after accepting" do
        patch accept_api_v1_appointment_request_path(@appointment_request), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        assert json["appointment_request"].present?
        assert_equal @appointment_request.id, json["appointment_request"]["id"]
        assert_equal "accepted", json["appointment_request"]["status"]
      end

      test "should send acceptance email when accepting" do
        assert_emails 1 do
          patch accept_api_v1_appointment_request_path(@appointment_request), as: :json
        end
      end

      test "should reject overlapping requests when accepting" do
        # Create overlapping pending request
        overlapping_request = AppointmentRequest.create!(
          nutritionist: @nutritionist,
          service: @service,
          guest_name: "Maria Santos",
          guest_email: "maria@example.com",
          desired_date: @appointment_request.desired_date,
          desired_time: @appointment_request.desired_time,
          status: "pending"
        )

        patch accept_api_v1_appointment_request_path(@appointment_request), as: :json

        assert_response :success

        # Overlapping request should be rejected
        overlapping_request.reload
        assert_equal "rejected", overlapping_request.status
      end

      test "should return 404 for nonexistent appointment request on accept" do
        patch accept_api_v1_appointment_request_path(id: 99999), as: :json

        assert_response :not_found

        json = JSON.parse(response.body)
        assert_equal false, json["success"]
        assert_equal "Appointment request not found", json["error"]
      end

      test "should return error when trying to accept already accepted request" do
        @appointment_request.update!(status: "accepted")

        patch accept_api_v1_appointment_request_path(@appointment_request), as: :json

        assert_response :unprocessable_entity

        json = JSON.parse(response.body)
        assert_equal false, json["success"]
        assert json["errors"].present?
      end

      # Reject endpoint tests
      test "should reject appointment request" do
        patch reject_api_v1_appointment_request_path(@appointment_request), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        assert_equal true, json["success"]
        assert_equal "Appointment request rejected", json["message"]

        # Check status changed
        @appointment_request.reload
        assert_equal "rejected", @appointment_request.status
      end

      test "should return appointment data after rejecting" do
        patch reject_api_v1_appointment_request_path(@appointment_request), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        assert json["appointment_request"].present?
        assert_equal @appointment_request.id, json["appointment_request"]["id"]
        assert_equal "rejected", json["appointment_request"]["status"]
      end

      test "should send rejection email when rejecting" do
        assert_emails 1 do
          patch reject_api_v1_appointment_request_path(@appointment_request), as: :json
        end
      end

      test "should return 404 for nonexistent appointment request on reject" do
        patch reject_api_v1_appointment_request_path(id: 99999), as: :json

        assert_response :not_found

        json = JSON.parse(response.body)
        assert_equal false, json["success"]
        assert_equal "Appointment request not found", json["error"]
      end

      test "should return error when trying to reject already rejected request" do
        @appointment_request.update!(status: "rejected")

        patch reject_api_v1_appointment_request_path(@appointment_request), as: :json

        assert_response :unprocessable_entity

        json = JSON.parse(response.body)
        assert_equal false, json["success"]
        assert json["errors"].present?
      end

      test "should include service data in response" do
        patch accept_api_v1_appointment_request_path(@appointment_request), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        service_data = json["appointment_request"]["service"]

        assert service_data.present?
        assert_equal @service.id, service_data["id"]
        assert_equal "Consulta Geral", service_data["name"]
        assert_equal "50.0", service_data["price"].to_s
      end

      test "should format time correctly in response" do
        patch accept_api_v1_appointment_request_path(@appointment_request), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        assert_match(/\A\d{2}:\d{2}\z/, json["appointment_request"]["desired_time"])
      end
    end
  end
end
