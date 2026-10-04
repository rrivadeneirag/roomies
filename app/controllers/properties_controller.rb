class PropertiesController < ApplicationController
  def index
    @properties = Property.includes(:neighborhood, :listings).order(:address)
  end

  def show
    @property = Property.includes(:neighborhood, :amenities, :host, listings: :photos)
                        .find(params[:id])
    @listings = @property.listings.includes(:photos, property: :neighborhood)
    @reviews = @property.reviews.includes(:visit)
  end
end
