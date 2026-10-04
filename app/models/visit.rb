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
  validate :scheduled_after_application_created

  scope :upcoming, -> { where("scheduled_at >= ?", Time.current) }

  private

  def scheduled_after_application_created
    return if scheduled_at.blank? || application.blank?

    created = application.created_at || Time.current
    if scheduled_at <= created
      errors.add(:scheduled_at, "must be after the application was created")
    end
  end
end
