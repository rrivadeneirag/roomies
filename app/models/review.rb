class Review < ApplicationRecord
  belongs_to :visit

  validates :rating, presence: true,
                     numericality: {
                       only_integer: true,
                       greater_than_or_equal_to: 1,
                       less_than_or_equal_to: 5
                     }
  validates :comment, presence: true
  validates :reviewed_on, presence: true
  validates :visit_id, uniqueness: true
  validate :visit_must_be_completed

  private

  def visit_must_be_completed
    return if visit.blank?

    errors.add(:visit, "must be completed before it can be reviewed") unless visit.completed?
  end
end
