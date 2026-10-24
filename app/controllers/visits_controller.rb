class VisitsController < ApplicationController
  before_action :set_visit, only: [:confirm, :cancel, :complete, :reschedule]

  def create
    @application = Application.find(params[:application_id])
    unless host_of?(@application)
      redirect_back fallback_location: @application, alert: "Only the host can propose a visit." and return
    end

    @visit = @application.visits.build(visit_params)
    if @visit.save
      redirect_to @application, notice: "Visit proposed."
    else
      redirect_to @application, alert: @visit.errors.full_messages.to_sentence
    end
  end

  def confirm
    @visit.update(status: :confirmed)
    redirect_to @visit.application, notice: "Visit confirmed."
  end

  def cancel
    @visit.update(status: :cancelled)
    redirect_to @visit.application, notice: "Visit cancelled."
  end

  def complete
    @visit.update(status: :completed)
    redirect_to @visit.application, notice: "Visit marked as completed."
  end

  def reschedule
    new_time = params[:scheduled_at]
    if new_time.present? && Time.zone.parse(new_time) >= Time.current
      @visit.update(scheduled_at: new_time, status: :proposed)
      redirect_to @visit.application, notice: "Visit rescheduled."
    else
      redirect_to @visit.application, alert: "Pick a future date and time to reschedule."
    end
  end

  private

  def set_visit
    @visit = Visit.find(params[:id])
  end

  def host_of?(application)
    application.listing.property.host_id == current_user.id
  end

  def visit_params
    params.require(:visit).permit(:scheduled_at)
  end
end
