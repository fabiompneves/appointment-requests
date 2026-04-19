class NutritionistsController < ApplicationController
  def index
    @query = params[:query].to_s.strip
    @location = location_param

    @nutritionists = if @query.present?
      Nutritionist.search(@query, @location).includes(:services)
    else
      Nutritionist.where(location: @location).includes(:services)
    end

    @nutritionists = @nutritionists.order(:name)
  end

  private

  def location_param
    location = params[:location].to_s.strip
    location.present? ? location : "Braga"
  end
end
