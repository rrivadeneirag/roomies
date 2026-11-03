class ReportPolicy < ApplicationPolicy
  def create? = user.present?
  def new?    = create?
  def index?  = moderator?
  def show?   = moderator?
  def update? = moderator?

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.moderator? ? scope.all : scope.none
    end
  end
end
