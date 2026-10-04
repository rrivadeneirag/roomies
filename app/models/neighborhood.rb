class Neighborhood < ApplicationRecord
  has_many :properties, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :city, presence: true
end
