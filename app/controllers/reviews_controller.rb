class ReviewsController < ApplicationController
  def create
    @visit = Visit.find(params[:visit_id])
    property = @visit.application.listing.property

    unless can_review?(@visit)
      redirect_to property, alert: "You can't review this visit." and return
    end

    @review = @visit.build_review(review_params)
    if @review.save
      redirect_to property, notice: "Review posted."
    else
      redirect_to property, alert: @review.errors.full_messages.to_sentence
    end
  end

  private

  def can_review?(visit)
    visit.completed? && visit.application.seeker_id == current_user.id && visit.review.nil?
  end

  def review_params
    params.require(:review).permit(:rating, :comment, :matched).merge(reviewed_on: Date.current)
  end
end
