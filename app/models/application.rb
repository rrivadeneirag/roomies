class Application < ApplicationRecord
  enum :status, {
    pending: "Pending",
    shortlisted: "Shortlisted",
    accepted: "Accepted",
    rejected: "Rejected",
    withdrawn: "Withdrawn"
  }

  belongs_to :listing
  belongs_to :seeker, class_name: "User"

  has_many :visits, dependent: :destroy

  validates :message, presence: true
  validates :move_in_on, presence: true
  validates :stay_months, presence: true,
                          numericality: { only_integer: true, greater_than: 0 }
  validates :status, presence: true
  validates :seeker_id, uniqueness: {
    scope: :listing_id, message: "has already applied to this listing"
  }

  scope :pending_answer, -> { where(status: [statuses[:pending], statuses[:shortlisted]]) }
end
