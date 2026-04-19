class AppointmentRequestMailer < ApplicationMailer
  def request_accepted(appointment_request)
    @appointment_request = appointment_request
    @nutritionist = appointment_request.nutritionist
    @service = appointment_request.service
    
    mail(
      to: appointment_request.guest_email,
      subject: "Consulta Confirmada - #{@nutritionist.name}"
    )
  end

  def request_rejected(appointment_request)
    @appointment_request = appointment_request
    @nutritionist = appointment_request.nutritionist
    @service = appointment_request.service
    
    mail(
      to: appointment_request.guest_email,
      subject: "Pedido de Consulta - #{@nutritionist.name}"
    )
  end
end
