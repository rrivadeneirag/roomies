class ListingPolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  def create? = host?
  def update? = host?
  def publish? = host?
  def mark_rented? = host?
  # Moderators can take a listing down, not only its host.
  def withdraw? = host? || moderator?
  def destroy? = host? || moderator?

  private

  def host?
    user.present? && record.property.host_id == user.id
  end
end
