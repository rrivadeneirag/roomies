class ApplicationsController < ApplicationController
  before_action :set_application, only: [:show, :destroy, :shortlist, :reject, :accept, :withdraw]
  before_action :set_listing, only: [:create]

  def index
    @incoming = Application.joins(listing: :property)
                          .where(properties: { host_id: current_user.id })
                          .includes(:seeker, :visits, listing: :property)
                          .order(created_at: :desc)
    @pending_count = host_pending_count

    @my_applications = current_user.applications
                                   .includes(listing: :property)
                                   .order(created_at: :desc)
  end

  def show
    @listing = @application.listing
    @visits = @application.visits.order(:scheduled_at)
  end

  def create
    @application = @listing.applications.build(application_params)
    @application.seeker = current_user
    if @application.save
      redirect_to @listing, notice: "Application sent."
    else
      redirect_to @listing, alert: @application.errors.full_messages.to_sentence
    end
  end

  def destroy
    listing = @application.listing
    @application.destroy
    redirect_to listing, notice: "Application removed.", status: :see_other
  end

  # --- Seeker action ---
  def withdraw
    if @application.seeker == current_user && @application.withdrawable?
      @application.update(status: :withdrawn)
      redirect_back fallback_location: @application.listing, notice: "Application withdrawn."
    else
      redirect_back fallback_location: root_path, alert: "You can't withdraw this application."
    end
  end

  # --- Host actions (answer with a Turbo Stream so the inbox updates in place) ---
  def shortlist
    return unless host_of?(@application)

    @application.update(status: :shortlisted)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: row_and_count_streams(@application) }
      format.html { redirect_back fallback_location: applications_path, notice: "Application shortlisted." }
    end
  end

  def reject
    return unless host_of?(@application)

    @application.update(status: :rejected)
    respond_to do |format|
      format.turbo_stream { render turbo_stream: row_and_count_streams(@application) }
      format.html { redirect_back fallback_location: applications_path, notice: "Application rejected." }
    end
  end

  def accept
    return unless host_of?(@application)

    unless @application.listing.published? && (@application.pending? || @application.shortlisted?)
      redirect_back fallback_location: applications_path, alert: "This application can't be accepted." and return
    end

    # Capture the applications that will be auto-rejected, so we can refresh their rows too.
    rejected = @application.listing.applications
                          .where.not(id: @application.id)
                          .where(status: [Application.statuses[:pending], Application.statuses[:shortlisted]])
                          .to_a
    @application.accept!

    respond_to do |format|
      format.turbo_stream do
        streams = [turbo_stream.replace(@application, partial: "applications/application_row",
                                        locals: { application: @application })]
        rejected.each do |app|
          app.reload
          streams << turbo_stream.replace(app, partial: "applications/application_row",
                                          locals: { application: app })
        end
        streams << turbo_stream.update("pending_count", host_pending_count)
        render turbo_stream: streams
      end
      format.html do
        redirect_back fallback_location: applications_path,
                      notice: "Application accepted. The room is now reserved."
      end
    end
  end

  private

  def set_application
    @application = Application.find(params[:id])
  end

  def set_listing
    @listing = Listing.find(params[:listing_id])
  end

  def host_of?(application)
    return true if application.listing.property.host_id == current_user.id

    redirect_back fallback_location: applications_path, alert: "Only the host can do that."
    false
  end

  def host_pending_count
    Application.joins(listing: :property)
               .where(properties: { host_id: current_user.id })
               .where(status: [Application.statuses[:pending], Application.statuses[:shortlisted]])
               .count
  end

  def row_and_count_streams(application)
    [
      turbo_stream.replace(application, partial: "applications/application_row",
                           locals: { application: application }),
      turbo_stream.update("pending_count", host_pending_count)
    ]
  end

  def application_params
    params.require(:application).permit(:message, :move_in_on, :stay_months)
  end
end
