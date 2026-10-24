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
  validate :listing_open_for_applications, on: :create
  validate :not_applying_to_own_property, on: :create

  scope :pending_answer, -> { where(status: [statuses[:pending], statuses[:shortlisted]]) }

  def withdrawable?
    pending? || shortlisted?
  end

  # Accept this application: reject every other open application on the listing and
  # move the listing to "reserved" — all three effects happen together or not at all.
  def accept!
    transaction do
      listing.applications
             .where.not(id: id)
             .where(status: [self.class.statuses[:pending], self.class.statuses[:shortlisted]])
             .update_all(status: self.class.statuses[:rejected], updated_at: Time.current)
      update!(status: :accepted)
      listing.update!(status: :reserved)
    end
  end

  private

  def listing_open_for_applications
    return if listing.blank?

    errors.add(:base, "This room is not open for applications.") unless listing.accepting_applications?
  end

  def not_applying_to_own_property
    return if listing.blank? || seeker_id.blank?

    errors.add(:base, "You cannot apply to your own property.") if listing.property.host_id == seeker_id
  end
end
