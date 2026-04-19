class AppointmentRequestMailer < ApplicationMailer
  def request_accepted(appointment_request)
    @appointment_request = appointment_request
    @nutritionist = appointment_request.nutritionist
    @service = appointment_request.service

    mail(
      to: appointment_request.guest_email,
      subject: "Appointment Confirmed - #{@nutritionist.name}"
    )
  end

  def request_rejected(appointment_request)
    @appointment_request = appointment_request
    @nutritionist = appointment_request.nutritionist
    @service = appointment_request.service

    mail(
      to: appointment_request.guest_email,
      subject: "Appointment Request - #{@nutritionist.name}"
    )
  end
end
