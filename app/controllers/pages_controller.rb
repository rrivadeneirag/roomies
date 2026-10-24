class PagesController < ApplicationController
  def home
    @featured_listings = Listing.published
                                .with_attached_photos
                                .includes(property: :neighborhood)
                                .order(available_on: :asc)
                                .limit(3)
    @neighborhoods = Neighborhood.order(:name)
  end
end
