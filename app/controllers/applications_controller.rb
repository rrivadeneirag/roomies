class ApplicationsController < ApplicationController
  def index
    @applications = Application.includes(:seeker, listing: { property: :neighborhood })
                              .order(created_at: :desc)
    @pending = Application.pending_answer.count
  end

  def show
    @application = Application.includes(:seeker, :visits, listing: { property: :neighborhood })
                             .find(params[:id])
    @listing = @application.listing
    @visits = @application.visits.order(:scheduled_at)
  end
end
