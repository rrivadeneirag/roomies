class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  helper_method :current_user,
              :pending_applications_count

private

def pending_applications_count
  return @pending_applications_count if
    defined?(@pending_applications_count)
  @pending_applications_count =
    if current_user
      Application.joins(listing: :property)
        .where(properties: {
          host_id: current_user.id })
        .where(status: ["Pending",
          "Shortlisted"]).count
    else
      0
    end
end

