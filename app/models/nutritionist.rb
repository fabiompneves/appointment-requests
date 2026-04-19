class Nutritionist < ApplicationRecord
  has_many :services, dependent: :destroy
  has_many :appointment_requests, dependent: :destroy

  validates :name, presence: true
  validates :location, presence: true

  scope :search, ->(query, location) {
    joins(:services)
      .where("nutritionists.location ILIKE ?", "%#{sanitize_sql_like(location)}%")
      .where(
        "nutritionists.name ILIKE ? OR services.name ILIKE ?",
        "%#{sanitize_sql_like(query)}%",
        "%#{sanitize_sql_like(query)}%"
      )
      .distinct
  }
end
