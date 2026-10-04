class NeighborhoodsController < ApplicationController
  def index
    @neighborhoods = Neighborhood.includes(:properties).order(:name)
  end

  def show
    @neighborhood = Neighborhood.find(params[:id])
    @properties = @neighborhood.properties.includes(:listings)
    @listings = Listing.published
                       .where(property_id: @properties.map(&:id))
                       .includes(:photos, property: :neighborhood)
                       .order(available_on: :asc)
  end
end
