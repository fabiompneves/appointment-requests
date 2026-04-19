require "test_helper"

class AppointmentRequestMailerTest < ActionMailer::TestCase
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

  test "request_accepted sends email with correct details" do
    mail = AppointmentRequestMailer.request_accepted(@appointment_request)
    
    assert_equal "Consulta Confirmada - Dra. Ana Silva", mail.subject
    assert_equal ["joao@example.com"], mail.to
    assert_equal ["noreply@nutricionistas.pt"], mail.from
    
    body = mail.body.encoded
    assert_match "Jo", body  
    assert_match "Silva", body
    assert_match "Dra. Ana Silva", body
    assert_match "Consulta Geral", body
    assert_match "50", body
  end

  test "request_rejected sends email with correct details" do
    mail = AppointmentRequestMailer.request_rejected(@appointment_request)
    
    assert_equal "Pedido de Consulta - Dra. Ana Silva", mail.subject
    assert_equal ["joao@example.com"], mail.to
    assert_equal ["noreply@nutricionistas.pt"], mail.from
    
    body = mail.body.encoded
    assert_match "Jo", body  
    assert_match "Silva", body
    assert_match "Dra. Ana Silva", body
    assert_match "Consulta Geral", body
  end

  test "request_accepted email includes HTML and text parts" do
    mail = AppointmentRequestMailer.request_accepted(@appointment_request)
    
    assert_equal 2, mail.parts.length
    assert_equal "text/plain", mail.parts.first.content_type.split(";").first
    assert_equal "text/html", mail.parts.last.content_type.split(";").first
  end

  test "request_rejected email includes HTML and text parts" do
    mail = AppointmentRequestMailer.request_rejected(@appointment_request)
    
    assert_equal 2, mail.parts.length
    assert_equal "text/plain", mail.parts.first.content_type.split(";").first
    assert_equal "text/html", mail.parts.last.content_type.split(";").first
  end
end
