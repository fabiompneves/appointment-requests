class AppointmentRequestDecisionService
  attr_reader :appointment_request, :errors

  def initialize(appointment_request)
    @appointment_request = appointment_request
    @errors = []
  end

  def accept
    return false unless validate_can_accept

    overlapping_requests_to_notify = []

    ActiveRecord::Base.transaction do
      overlapping_requests_to_notify = find_overlapping_requests.to_a

      reject_overlapping_requests

      appointment_request.update!(status: "accepted")
    end

    send_acceptance_email
    send_rejection_emails_for_overlapping(overlapping_requests_to_notify)

    true
  rescue StandardError => e
    @errors << e.message
    false
  end

  def reject
    return false unless validate_can_reject

    appointment_request.update!(status: "rejected")

    send_rejection_email

    true
  rescue StandardError => e
    @errors << e.message
    false
  end

  private

  def validate_can_accept
    unless appointment_request.pending?
      @errors << "Only pending requests can be accepted"
      return false
    end
    true
  end

  def validate_can_reject
    unless appointment_request.pending?
      @errors << "Only pending requests can be rejected"
      return false
    end
    true
  end

  def find_overlapping_requests
    AppointmentRequest
      .pending
      .where(
        nutritionist_id: appointment_request.nutritionist_id,
        desired_date: appointment_request.desired_date,
        desired_time: appointment_request.desired_time
      )
      .where.not(id: appointment_request.id)
  end

  def reject_overlapping_requests
    find_overlapping_requests.update_all(status: "rejected")
  end

  def send_acceptance_email
    AppointmentRequestMailer.request_accepted(appointment_request).deliver_later
  end

  def send_rejection_email
    AppointmentRequestMailer.request_rejected(appointment_request).deliver_later
  end

  def send_rejection_emails_for_overlapping(requests)
    requests.each do |request|
      request.reload
      AppointmentRequestMailer.request_rejected(request).deliver_later
    end
  end
end
