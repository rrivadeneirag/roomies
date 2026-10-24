class ListingsController < ApplicationController
  before_action :set_listing, only: [:show, :edit, :update, :destroy, :publish, :withdraw, :mark_rented]
  before_action :set_property, only: [:new, :create]

  def index
    scope = Listing.published
                   .joins(:property)
                   .with_attached_photos
                   .includes(property: :neighborhood)

    scope = scope.where(properties: { neighborhood_id: params[:neighborhood] }) if params[:neighborhood].present?
    scope = scope.under_rent(params[:max_rent]) if params[:max_rent].present?
    scope = scope.available_from(params[:available_on]) if params[:available_on].present?

    @listings = scope.order(available_on: :asc)
  end

  def show
    @property = @listing.property
    if @listing.draft? && current_user != @property.host
      redirect_to listings_path, alert: "That room is not published yet." and return
    end
    @reviews = @property.reviews.includes(:visit)
    @application = @listing.applications.find_by(seeker: current_user)
  end

  def new
    @listing = @property.listings.build
  end

  def create
    @listing = @property.listings.build(listing_params)
    if @listing.save
      redirect_to @listing, notice: "Listing created as draft."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @listing.update(listing_params)
      redirect_to @listing, notice: "Listing updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    property = @listing.property
    @listing.destroy
    redirect_to property, notice: "Listing deleted.", status: :see_other
  end

  def publish
    @listing.publish!
    redirect_to @listing, notice: "Listing published."
  end

  def withdraw
    @listing.withdraw!
    redirect_to @listing, notice: "Listing withdrawn."
  end

  def mark_rented
    @listing.mark_rented!
    redirect_to @listing, notice: "Listing marked as rented."
  end

  private

  def set_listing
    @listing = Listing.find(params[:id])
  end

  def set_property
    @property = Property.find(params[:property_id])
  end

  def listing_params
    permitted = params.require(:listing).permit(
      :monthly_rent, :deposit, :available_on, :minimum_stay_months,
      :furnished, :private_bathroom, :description, :house_rules, photos: []
    )

    # Keep existing photos when no new file is chosen (avoid purging on edit).
    if permitted[:photos]
      cleaned = permitted[:photos].reject(&:blank?)
      cleaned.any? ? permitted[:photos] = cleaned : permitted.delete(:photos)
    end

    permitted
  end
end
