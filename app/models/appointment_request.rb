class AppointmentRequest < ApplicationRecord
  belongs_to :nutritionist
  belongs_to :service

  validates :guest_name, presence: true
  validates :guest_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :desired_date, presence: true
  validates :desired_time, presence: true
  validates :status, presence: true, inclusion: { in: %w[pending accepted rejected invalidated] }

  scope :pending, -> { where(status: "pending") }
  scope :for_guest, ->(email) { where(guest_email: email) }
  scope :for_nutritionist, ->(nutritionist_id) { where(nutritionist_id: nutritionist_id) }
  scope :overlapping, ->(nutritionist_id, date, time) {
    where(nutritionist_id: nutritionist_id, desired_date: date, desired_time: time)
  }

  def pending?
    status == "pending"
  end

  def accepted?
    status == "accepted"
  end

  def rejected?
    status == "rejected"
  end

  def invalidated?
    status == "invalidated"
  end
end
