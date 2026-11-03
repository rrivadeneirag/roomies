class PropertyPolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  def create? = user.present?
  def update? = owner?
  def destroy? = owner? || moderator?

  private

  def owner?
    user.present? && record.host_id == user.id
  end
end
