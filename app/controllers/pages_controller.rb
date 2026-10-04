class PagesController < ApplicationController
  def home
    @featured_listings = Listing.published
                                .includes(:photos, property: :neighborhood)
                                .order(available_on: :asc)
                                .limit(3)
    @neighborhoods = Neighborhood.order(:name)
  end
end
