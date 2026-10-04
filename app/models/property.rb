class Property < ApplicationRecord
  belongs_to :host, class_name: "User"
  belongs_to :neighborhood

  has_many :property_amenities, dependent: :destroy
  has_many :amenities, through: :property_amenities
  has_many :listings, dependent: :destroy
  has_many :applications, through: :listings
  has_many :visits, through: :applications
  has_many :reviews, through: :visits, source: :review

  validates :address, presence: true
  validates :property_type, presence: true
  validates :bedrooms, presence: true,
                       numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :bathrooms, presence: true,
                        numericality: { only_integer: true, greater_than_or_equal_to: 0 }
end
