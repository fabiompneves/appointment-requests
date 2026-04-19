class Service < ApplicationRecord
  belongs_to :nutritionist
  has_many :appointment_requests, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
end
