require "test_helper"

class AppointmentRequestTest < ActiveSupport::TestCase
  def setup
    @nutritionist = Nutritionist.create!(name: "Dra. Test", location: "Porto")
    @service = @nutritionist.services.create!(name: "Consulta Geral", price: 50)
    @appointment_request = AppointmentRequest.new(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "João Silva",
      guest_email: "joao@example.com",
      desired_date: Date.tomorrow,
      desired_time: Time.zone.parse("10:00"),
      status: "pending"
    )
  end

  test "should be valid with valid attributes" do
    assert @appointment_request.valid?
  end

  test "should require guest_name" do
    @appointment_request.guest_name = nil
    assert_not @appointment_request.valid?
  end

  test "should require guest_email" do
    @appointment_request.guest_email = nil
    assert_not @appointment_request.valid?
  end

  test "should validate email format" do
    @appointment_request.guest_email = "invalid_email"
    assert_not @appointment_request.valid?
    assert_includes @appointment_request.errors[:guest_email], "is invalid"
  end

  test "should require desired_date" do
    @appointment_request.desired_date = nil
    assert_not @appointment_request.valid?
  end

  test "should require desired_time" do
    @appointment_request.desired_time = nil
    assert_not @appointment_request.valid?
  end

  test "should validate status inclusion" do
    @appointment_request.status = "invalid_status"
    assert_not @appointment_request.valid?
    assert_includes @appointment_request.errors[:status], "is not included in the list"
  end

  test "should default status to pending" do
    request = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Test",
      guest_email: "test@example.com",
      desired_date: Date.tomorrow,
      desired_time: Time.zone.parse("10:00")
    )
    assert_equal "pending", request.status
  end

  test "should belong to nutritionist" do
    assert_equal @nutritionist, @appointment_request.nutritionist
  end

  test "should belong to service" do
    assert_equal @service, @appointment_request.service
  end

  test "pending scope should return only pending requests" do
    pending = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Pending User",
      guest_email: "pending@example.com",
      desired_date: Date.tomorrow,
      desired_time: Time.zone.parse("10:00"),
      status: "pending"
    )

    accepted = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Accepted User",
      guest_email: "accepted@example.com",
      desired_date: Date.tomorrow,
      desired_time: Time.zone.parse("11:00"),
      status: "accepted"
    )

    assert_includes AppointmentRequest.pending, pending
    assert_not_includes AppointmentRequest.pending, accepted
  end

  test "for_guest scope should filter by email" do
    guest_email = "specific@example.com"

    matching = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Match",
      guest_email: guest_email,
      desired_date: Date.tomorrow,
      desired_time: Time.zone.parse("10:00")
    )

    other = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Other",
      guest_email: "other@example.com",
      desired_date: Date.tomorrow,
      desired_time: Time.zone.parse("11:00")
    )

    results = AppointmentRequest.for_guest(guest_email)
    assert_includes results, matching
    assert_not_includes results, other
  end

  test "overlapping scope should find requests with same nutritionist, date, and time" do
    date = Date.tomorrow
    time = Time.zone.parse("14:00")

    original = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Original",
      guest_email: "original@example.com",
      desired_date: date,
      desired_time: time
    )

    overlapping = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Overlap",
      guest_email: "overlap@example.com",
      desired_date: date,
      desired_time: time
    )

    different_time = AppointmentRequest.create!(
      nutritionist: @nutritionist,
      service: @service,
      guest_name: "Different",
      guest_email: "different@example.com",
      desired_date: date,
      desired_time: Time.zone.parse("15:00")
    )

    results = AppointmentRequest.overlapping(@nutritionist.id, date, time)
    assert_includes results, original
    assert_includes results, overlapping
    assert_not_includes results, different_time
  end

  test "pending? should return true for pending status" do
    @appointment_request.status = "pending"
    assert @appointment_request.pending?
  end

  test "accepted? should return true for accepted status" do
    @appointment_request.status = "accepted"
    assert @appointment_request.accepted?
  end

  test "rejected? should return true for rejected status" do
    @appointment_request.status = "rejected"
    assert @appointment_request.rejected?
  end

  test "invalidated? should return true for invalidated status" do
    @appointment_request.status = "invalidated"
    assert @appointment_request.invalidated?
  end
end
