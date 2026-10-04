class User < ApplicationRecord
  enum :role, { member: "member", moderator: "moderator" }

  has_many :properties, foreign_key: :host_id, inverse_of: :host, dependent: :destroy
  has_many :applications, foreign_key: :seeker_id, inverse_of: :seeker, dependent: :destroy
  has_many :saved_listings, dependent: :destroy
  has_many :saved_rooms, through: :saved_listings, source: :listing
  has_many :filed_reports, class_name: "Report", foreign_key: :reporter_id,
                           inverse_of: :reporter, dependent: :destroy
  has_many :handled_reports, class_name: "Report", foreign_key: :moderator_id,
                             inverse_of: :moderator, dependent: :nullify

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password_digest, presence: true
  validates :role, presence: true
end
