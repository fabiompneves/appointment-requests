require "test_helper"

class AppointmentRequestsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @nutritionist = Nutritionist.create!(name: "Dra. Test", location: "Porto")
    @service = @nutritionist.services.create!(name: "Consulta Geral", price: 50)
  end

  test "should get new" do
    get new_appointment_request_path(nutritionist_id: @nutritionist.id)
    assert_response :success
  end

  test "should create appointment request with valid data" do
    assert_difference("AppointmentRequest.count") do
      post appointment_requests_path, params: {
        appointment_request: {
          nutritionist_id: @nutritionist.id,
          service_id: @service.id,
          guest_name: "João Silva",
          guest_email: "joao@example.com",
          desired_date: Date.tomorrow,
          desired_time: "10:00"
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Pedido de consulta enviado com sucesso! Aguarde confirmação do nutricionista.", flash[:notice]
  end

  test "should invalidate previous pending request from same guest" do
    guest_email = "same@example.com"

    # Create first pending request
    first_request = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Test Guest",
      guest_email: guest_email,
      desired_date: Date.tomorrow,
      desired_time: Time.zone.parse("10:00"),
      status: "pending"
    )

    # Create second request from same guest (should create new and invalidate old)
    assert_difference("AppointmentRequest.count", 1) do
      post appointment_requests_path, params: {
        appointment_request: {
          nutritionist_id: @nutritionist.id,
          service_id: @service.id,
          guest_name: "Test Guest",
          guest_email: guest_email,
          desired_date: Date.tomorrow + 1.day,
          desired_time: "11:00"
        }
      }
    end

    # First request should be invalidated
    assert_equal "invalidated", first_request.reload.status

    # New request should be pending
    new_request = AppointmentRequest.last
    assert_equal "pending", new_request.status
    assert_equal guest_email, new_request.guest_email
  end

  test "should not create appointment request with invalid data" do
    assert_no_difference("AppointmentRequest.count") do
      post appointment_requests_path, params: {
        appointment_request: {
          nutritionist_id: @nutritionist.id,
          service_id: @service.id,
          guest_name: "",  # Invalid: empty name
          guest_email: "invalid_email",  # Invalid: bad format
          desired_date: Date.tomorrow,
          desired_time: "10:00"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should require nutritionist_id" do
    get new_appointment_request_path
    assert_response :not_found
  end
end
