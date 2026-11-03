class ReportsController < ApplicationController
  before_action :set_report, only: [:update]

  # Moderator inbox: every report, newest first.
  def index
    authorize Report
    @reports = policy_scope(Report)
               .includes(:listing, :reporter, :moderator)
               .order(created_at: :desc)
  end

  # Any signed-in user can flag a listing.
  def create
    @listing = Listing.find(params[:listing_id])
    @report = @listing.reports.new(report_params)
    @report.reporter = current_user
    authorize @report
    if @report.save
      redirect_to @listing, notice: "Thanks — your report was sent to the moderators."
    else
      redirect_to @listing, alert: "Please add a reason before reporting."
    end
  end

  # Moderator resolves a report (sets its status and records who handled it).
  def update
    authorize @report
    if @report.update(status: report_params[:status], moderator: current_user)
      redirect_to reports_path, notice: "Report updated."
    else
      redirect_to reports_path, alert: "Could not update the report."
    end
  end

  private

  def set_report
    @report = Report.find(params[:id])
  end

  def report_params
    params.require(:report).permit(:reason, :status)
  end
end
