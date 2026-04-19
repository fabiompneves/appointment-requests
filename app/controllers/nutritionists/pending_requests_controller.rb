class Nutritionists::PendingRequestsController < ApplicationController
  def index
    @nutritionist_id = params[:nutritionist_id] || 1
  end
end
