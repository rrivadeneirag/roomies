class AmenityPolicy < ApplicationPolicy
  def index? = true
  def show?  = true
  def create? = moderator?
  def update? = moderator?
  def destroy? = moderator?
end
