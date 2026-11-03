class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization

  allow_browser versions: :modern

  helper_method :current_user, :pending_applications_count

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  # The current user is the one who signed in (from the Rails 8 auth session).
  def current_user
    # On public pages (allow_unauthenticated_access) the session is not resumed
    # by a before_action, so resume it here before reading the current user.
    resume_session
    Current.user
  end

  def user_not_authorized
    render "pages/forbidden", status: :forbidden
  end

  def pending_applications_count
    return @pending_applications_count if defined?(@pending_applications_count)

    @pending_applications_count =
      if current_user
        Application.joins(listing: :property)
                   .where(properties: { host_id: current_user.id })
                   .where(status: ["Pending", "Shortlisted"]).count
      else
        0
      end
  end
end
