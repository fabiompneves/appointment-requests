class AppointmentRequestsController < ApplicationController
  def new
    @nutritionist = Nutritionist.find(params[:nutritionist_id])
    @appointment_request = AppointmentRequest.new(nutritionist: @nutritionist)
  end

  def create
    @nutritionist = Nutritionist.find(params[:appointment_request][:nutritionist_id])
    @appointment_request = AppointmentRequest.new(appointment_request_params)

    if @appointment_request.valid?
      AppointmentRequest.pending
        .for_guest(@appointment_request.guest_email)
        .update_all(status: "invalidated")

      @appointment_request.save!

      redirect_to root_path, notice: "Appointment request sent successfully! Awaiting nutritionist confirmation."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def appointment_request_params
    params.require(:appointment_request).permit(
      :nutritionist_id,
      :service_id,
      :guest_name,
      :guest_email,
      :desired_date,
      :desired_time
    )
  end
end
