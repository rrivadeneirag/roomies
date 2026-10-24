class Listing < ApplicationRecord
  enum :status, {
    draft: "Draft",
    published: "Published",
    reserved: "Reserved",
    rented: "Rented",
    withdrawn: "Withdrawn"
  }

  MAX_PHOTO_SIZE = 5.megabytes
  ALLOWED_PHOTO_TYPES = %w[image/png image/jpeg image/jpg image/webp image/gif].freeze

  belongs_to :property

  has_rich_text :description
  has_rich_text :house_rules
  has_many_attached :photos

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
  validate :photos_are_valid

  # `published` scope is provided automatically by the status enum
  scope :available_from, ->(date) { where("available_on >= ?", date) }
  scope :under_rent, ->(amount) { where("monthly_rent <= ?", amount) }

  # --- Listing lifecycle ---
  def publish!
    update(status: :published) if draft?
  end

  def withdraw!
    update(status: :withdrawn) unless rented? || withdrawn?
  end

  def mark_rented!
    update(status: :rented) if published? || reserved?
  end

  # A listing stops accepting applications once it is no longer open.
  def accepting_applications?
    published?
  end

  private

  def available_on_not_in_past
    return if available_on.blank?

    errors.add(:available_on, "can't be in the past") if available_on < Date.current
  end

  def photos_are_valid
    photos.each do |photo|
      unless photo.content_type.in?(ALLOWED_PHOTO_TYPES)
        errors.add(:photos, "must be images (PNG, JPG, WEBP or GIF)")
      end
      if photo.blob.byte_size > MAX_PHOTO_SIZE
        errors.add(:photos, "must each be smaller than 5 MB")
      end
    end
  end
end
