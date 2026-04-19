require "test_helper"

module Api
  module V1
    class NutritionistsControllerTest < ActionDispatch::IntegrationTest
      def setup
        @nutritionist = Nutritionist.create!(name: "Dra. Ana Silva", location: "Porto")
        @service1 = @nutritionist.services.create!(name: "Consulta Geral", price: 50)
        @service2 = @nutritionist.services.create!(name: "Nutrição Desportiva", price: 60)

        # Create pending requests
        @pending_request1 = AppointmentRequest.create!(
          nutritionist: @nutritionist,
          service: @service1,
          guest_name: "João Silva",
          guest_email: "joao@example.com",
          desired_date: Date.tomorrow,
          desired_time: Time.zone.parse("10:00"),
          status: "pending"
        )

        @pending_request2 = AppointmentRequest.create!(
          nutritionist: @nutritionist,
          service: @service2,
          guest_name: "Maria Santos",
          guest_email: "maria@example.com",
          desired_date: Date.tomorrow + 1.day,
          desired_time: Time.zone.parse("14:00"),
          status: "pending"
        )

        # Create accepted request (should not appear)
        AppointmentRequest.create!(
          nutritionist: @nutritionist,
          service: @service1,
          guest_name: "Carlos Costa",
          guest_email: "carlos@example.com",
          desired_date: Date.tomorrow,
          desired_time: Time.zone.parse("11:00"),
          status: "accepted"
        )
      end

      test "should return pending requests for nutritionist" do
        get pending_requests_api_v1_nutritionist_path(@nutritionist), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        assert_equal true, json["success"]

        # Check nutritionist data
        assert_equal @nutritionist.id, json["nutritionist"]["id"]
        assert_equal "Dra. Ana Silva", json["nutritionist"]["name"]
        assert_equal "Porto", json["nutritionist"]["location"]

        # Check requests data
        assert_equal 2, json["requests"].size

        # First request
        first_request = json["requests"].first
        assert_equal @pending_request1.id, first_request["id"]
        assert_equal "João Silva", first_request["guest_name"]
        assert_equal "joao@example.com", first_request["guest_email"]
        assert_equal "pending", first_request["status"]
        assert_equal "10:00", first_request["desired_time"]

        # Service data
        assert_equal @service1.id, first_request["service"]["id"]
        assert_equal "Consulta Geral", first_request["service"]["name"]
        assert_equal 50.0, first_request["service"]["price"]
      end

      test "should return empty array when no pending requests" do
        @nutritionist.appointment_requests.update_all(status: "accepted")

        get pending_requests_api_v1_nutritionist_path(@nutritionist), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        assert_equal true, json["success"]
        assert_equal 0, json["requests"].size
      end

      test "should order requests by date and time" do
        get pending_requests_api_v1_nutritionist_path(@nutritionist), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        dates = json["requests"].map { |r| r["desired_date"] }

        # Should be in ascending order
        assert_equal dates.sort, dates
      end

      test "should return 404 for nonexistent nutritionist" do
        get pending_requests_api_v1_nutritionist_path(id: 99999), as: :json

        assert_response :not_found

        json = JSON.parse(response.body)
        assert_equal false, json["success"]
        assert_equal "Nutritionist not found", json["error"]
      end

      test "should include service information for each request" do
        get pending_requests_api_v1_nutritionist_path(@nutritionist), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        json["requests"].each do |request|
          assert request["service"].present?
          assert request["service"]["id"].present?
          assert request["service"]["name"].present?
          assert request["service"]["price"].present?
        end
      end

      test "should format time as HH:MM" do
        get pending_requests_api_v1_nutritionist_path(@nutritionist), as: :json

        assert_response :success

        json = JSON.parse(response.body)
        json["requests"].each do |request|
          assert_match(/\A\d{2}:\d{2}\z/, request["desired_time"])
        end
      end
    end
  end
end
