class ListingsController < ApplicationController
  def index
    scope = Listing.published
                   .joins(:property)
                   .includes(:photos, property: :neighborhood)

    if params[:neighborhood].present?
      scope = scope.where(properties: { neighborhood_id: params[:neighborhood] })
    end
    scope = scope.under_rent(params[:max_rent]) if params[:max_rent].present?
    scope = scope.available_from(params[:available_on]) if params[:available_on].present?

    @listings = scope.order(available_on: :asc)
  end

  def show
    @listing = Listing.includes(:photos, property: [:neighborhood, :amenities, :host])
                      .find(params[:id])
    @property = @listing.property
    @reviews = @property.reviews.includes(:visit)
  end
end
