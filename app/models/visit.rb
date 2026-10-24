class Visit < ApplicationRecord
  enum :status, {
    proposed: "Proposed",
    confirmed: "Confirmed",
    cancelled: "Cancelled",
    completed: "Completed"
  }

  belongs_to :application
  has_one :review, dependent: :destroy

  validates :scheduled_at, presence: true
  validates :status, presence: true
  validate :not_in_past, on: :create
  validate :application_shortlisted, on: :create

  scope :upcoming, -> { where("scheduled_at >= ?", Time.current) }

  private

  def not_in_past
    return if scheduled_at.blank?

    errors.add(:scheduled_at, "can't be in the past") if scheduled_at < Time.current
  end

  def application_shortlisted
    return if application.blank?

    unless application.shortlisted?
      errors.add(:base, "A visit can only be proposed on a shortlisted application.")
    end
  end
end
