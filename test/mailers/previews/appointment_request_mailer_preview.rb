class AppointmentRequestMailerPreview < ActionMailer::Preview
  def request_accepted
    AppointmentRequestMailer.request_accepted
  end

  def request_rejected
    AppointmentRequestMailer.request_rejected
  end
end
