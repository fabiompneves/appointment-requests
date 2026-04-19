require "test_helper"

class AppointmentRequestDecisionServiceTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    @nutritionist = Nutritionist.create!(name: "Dra. Test", location: "Porto")
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

  test "should accept a pending request" do
    service = AppointmentRequestDecisionService.new(@appointment_request)

    assert service.accept
    assert_equal "accepted", @appointment_request.reload.status
  end

  test "should not accept non-pending request" do
    @appointment_request.update!(status: "rejected")
    service = AppointmentRequestDecisionService.new(@appointment_request)

    assert_not service.accept
    assert_includes service.errors, "Only pending requests can be accepted"
  end

  test "should reject overlapping pending requests when accepting" do
    date = Date.tomorrow
    time = Time.zone.parse("14:00")

    request1 = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Guest 1",
      guest_email: "guest1@example.com",
      desired_date: date,
      desired_time: time,
      status: "pending"
    )

    request2 = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Guest 2",
      guest_email: "guest2@example.com",
      desired_date: date,
      desired_time: time,
      status: "pending"
    )

    request3 = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Guest 3",
      guest_email: "guest3@example.com",
      desired_date: date,
      desired_time: time,
      status: "pending"
    )

    service = AppointmentRequestDecisionService.new(request1)
    assert service.accept

    assert_equal "accepted", request1.reload.status
    assert_equal "rejected", request2.reload.status
    assert_equal "rejected", request3.reload.status
  end

  test "should not reject non-overlapping requests when accepting" do
    date = Date.tomorrow

    request_14 = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Guest 14:00",
      guest_email: "guest14@example.com",
      desired_date: date,
      desired_time: Time.zone.parse("14:00"),
      status: "pending"
    )

    request_15 = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Guest 15:00",
      guest_email: "guest15@example.com",
      desired_date: date,
      desired_time: Time.zone.parse("15:00"),
      status: "pending"
    )

    service = AppointmentRequestDecisionService.new(request_14)
    assert service.accept

    assert_equal "accepted", request_14.reload.status
    assert_equal "pending", request_15.reload.status
  end

  test "should call mailer when accepting" do
    service = AppointmentRequestDecisionService.new(@appointment_request)
    assert service.accept
  end

  test "should handle overlapping requests with email notifications" do
    date = Date.tomorrow
    time = Time.zone.parse("14:00")

    request1 = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Guest 1",
      guest_email: "guest1@example.com",
      desired_date: date,
      desired_time: time,
      status: "pending"
    )

    request2 = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Guest 2",
      guest_email: "guest2@example.com",
      desired_date: date,
      desired_time: time,
      status: "pending"
    )

    request3 = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Guest 3",
      guest_email: "guest3@example.com",
      desired_date: date,
      desired_time: time,
      status: "pending"
    )

    service = AppointmentRequestDecisionService.new(request1)
    assert service.accept

    assert_equal "accepted", request1.reload.status
    assert_equal "rejected", request2.reload.status
    assert_equal "rejected", request3.reload.status
  end

  test "should reject a pending request" do
    service = AppointmentRequestDecisionService.new(@appointment_request)

    assert service.reject
    assert_equal "rejected", @appointment_request.reload.status
  end

  test "should not reject non-pending request" do
    @appointment_request.update!(status: "accepted")
    service = AppointmentRequestDecisionService.new(@appointment_request)

    assert_not service.reject
    assert_includes service.errors, "Only pending requests can be rejected"
  end

  test "should call mailer when rejecting" do
    service = AppointmentRequestDecisionService.new(@appointment_request)
    assert service.reject
  end
end
