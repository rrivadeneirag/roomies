class ListingsController < ApplicationController
  def index
    @listings = Listing.published
                       .includes(:photos, property: :neighborhood)
                       .order(available_on: :asc)
  end

  def show
    @listing = Listing.includes(:photos, property: [:neighborhood, :amenities, :host])
                      .find(params[:id])
    @property = @listing.property
    @reviews = @property.reviews.includes(:visit)
  end
end
