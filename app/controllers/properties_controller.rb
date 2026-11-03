class PropertiesController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_property, only: [:show, :edit, :update, :destroy]

  def index
    @properties = Property.includes(:neighborhood, :listings).order(:address)
  end

  def show
    scope = @property.listings.with_attached_photos.includes(property: :neighborhood)
    # The host sees every listing (including drafts); everyone else only published ones.
    @listings = (current_user == @property.host) ? scope : scope.published
    @reviews = @property.reviews.includes(:visit)

    # Completed visits by the current user on this property that have no review yet.
    @reviewable_visits = Visit.completed
                              .joins(application: { listing: :property })
                              .where(properties: { id: @property.id })
                              .where(applications: { seeker_id: current_user&.id })
                              .where.missing(:review)
                              .includes(application: { listing: :property })
  end

  def new
    @property = Property.new
    authorize @property
  end

  def create
    @property = Property.new(property_params)
    @property.host = current_user
    authorize @property
    if @property.save
      redirect_to @property, notice: "Property created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @property
  end

  def update
    authorize @property
    if @property.update(property_params)
      redirect_to @property, notice: "Property updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @property
    @property.destroy
    redirect_to properties_path, notice: "Property deleted.", status: :see_other
  end

  private

  def set_property
    @property = Property.find(params[:id])
  end

  def property_params
    params.require(:property).permit(:address, :neighborhood_id, :property_type,
                                     :bedrooms, :bathrooms, :shared_spaces,
                                     amenity_ids: [])
  end
end
