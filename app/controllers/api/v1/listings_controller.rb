module Api
  module V1
    class ListingsController < BaseController
      # GET /api/v1/listings
      # Optional filters: neighborhood, max_rent, available_on, furnished, property_type
      def index
        scope = Listing.published
                       .joins(:property)
                       .includes(property: :neighborhood)
                       .with_attached_photos

        scope = scope.where(properties: { neighborhood_id: params[:neighborhood] }) if params[:neighborhood].present?
        scope = scope.under_rent(params[:max_rent]) if params[:max_rent].present?
        scope = scope.available_from(params[:available_on]) if params[:available_on].present?
        scope = scope.where(furnished: true) if params[:furnished] == "true"
        scope = scope.where(properties: { property_type: params[:property_type] }) if params[:property_type].present?
        scope = scope.where(private_bathroom: true) if params[:private_bathroom] == "true" 

        @listings = scope.order(available_on: :asc)
      end

      # GET /api/v1/listings/:id
      def show
        @listing = Listing.published.includes(property: :neighborhood).find_by(id: params[:id])
        render json: { error: "Listing not found" }, status: :not_found if @listing.nil?
      end
    end
  end
end
