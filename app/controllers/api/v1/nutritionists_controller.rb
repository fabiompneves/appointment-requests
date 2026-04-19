module Api
  module V1
    class NutritionistsController < ApplicationController
      def pending_requests
        nutritionist = Nutritionist.find(params[:id])

        requests = nutritionist.appointment_requests
          .pending
          .includes(:service)
          .order(desired_date: :asc, desired_time: :asc)

        render json: {
          success: true,
          nutritionist: {
            id: nutritionist.id,
            name: nutritionist.name,
            location: nutritionist.location
          },
          requests: requests.map { |request| format_request(request) }
        }
      rescue ActiveRecord::RecordNotFound
        render json: { success: false, error: "Nutritionist not found" }, status: :not_found
      end

      private

      def format_request(request)
        {
          id: request.id,
          guest_name: request.guest_name,
          guest_email: request.guest_email,
          desired_date: request.desired_date,
          desired_time: request.desired_time.strftime("%H:%M"),
          status: request.status,
          service: {
            id: request.service.id,
            name: request.service.name,
            price: request.service.price.to_f
          },
          created_at: request.created_at,
          updated_at: request.updated_at
        }
      end
    end
  end
end
