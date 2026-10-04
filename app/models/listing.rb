class Listing < ApplicationRecord
  enum :status, {
    draft: "Draft",
    published: "Published",
    reserved: "Reserved",
    rented: "Rented",
    withdrawn: "Withdrawn"
  }

  belongs_to :property

  has_many :photos, -> { order(:position) }, dependent: :destroy
  has_many :applications, dependent: :destroy
  has_many :seekers, through: :applications, source: :seeker
  has_many :saved_listings, dependent: :destroy
  has_many :reports, dependent: :destroy

  has_one :neighborhood, through: :property
  has_one :host, through: :property

  validates :monthly_rent, presence: true, numericality: { greater_than: 0 }
  validates :deposit, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :minimum_stay_months, presence: true,
                                  numericality: { only_integer: true, greater_than: 0 }
  validates :available_on, presence: true
  validates :status, presence: true
  validate :available_on_not_in_past, on: :create

  # published is provided automatically by the status enum
  scope :available_from, ->(date) { where("available_on >= ?", date) }
  scope :under_rent, ->(amount) { where("monthly_rent <= ?", amount) }

  private

  def available_on_not_in_past
    return if available_on.blank?

    errors.add(:available_on, "can't be in the past") if available_on < Date.current
  end
end
