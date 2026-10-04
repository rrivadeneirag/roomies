class Report < ApplicationRecord
  enum :status, {
    pending: "Pending",
    reviewed: "Reviewed",
    dismissed: "Dismissed",
    action_taken: "ActionTaken"
  }

  belongs_to :listing
  belongs_to :reporter, class_name: "User"
  belongs_to :moderator, class_name: "User", optional: true

  validates :reason, presence: true
  validates :status, presence: true
end
