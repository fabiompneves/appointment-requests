module Api
  module V1
    class AppointmentRequestsController < ApplicationController
      before_action :set_appointment_request, only: [:accept, :reject]
      
      def accept
        service = AppointmentRequestDecisionService.new(@appointment_request)
        
        if service.accept
          render json: {
            success: true,
            message: 'Appointment request accepted successfully',
            appointment_request: appointment_request_json(@appointment_request.reload)
          }
        else
          render json: {
            success: false,
            errors: service.errors
          }, status: :unprocessable_entity
        end
      end
      
      def reject
        service = AppointmentRequestDecisionService.new(@appointment_request)
        
        if service.reject
          render json: {
            success: true,
            message: 'Appointment request rejected',
            appointment_request: appointment_request_json(@appointment_request.reload)
          }
        else
          render json: {
            success: false,
            errors: service.errors
          }, status: :unprocessable_entity
        end
      end
      
      private
      
      def set_appointment_request
        @appointment_request = AppointmentRequest.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { success: false, error: 'Appointment request not found' }, status: :not_found
      end
      
      def appointment_request_json(request)
        {
          id: request.id,
          guest_name: request.guest_name,
          guest_email: request.guest_email,
          desired_date: request.desired_date,
          desired_time: request.desired_time.strftime('%H:%M'),
          status: request.status,
          service: {
            id: request.service.id,
            name: request.service.name,
            price: request.service.price
          },
          created_at: request.created_at
        }
      end
    end
  end
end
