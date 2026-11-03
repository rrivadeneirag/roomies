class NeighborhoodsController < ApplicationController
  allow_unauthenticated_access only: %i[ index show ]
  before_action :set_neighborhood, only: [:show, :edit, :update, :destroy]

  def index
    @neighborhoods = Neighborhood.includes(:properties).order(:name)
  end

  def show
    @properties = @neighborhood.properties.includes(:listings)
    @listings = Listing.published
                       .where(property_id: @properties.map(&:id))
                       .with_attached_photos
                       .includes(property: :neighborhood)
                       .order(available_on: :asc)
  end

  def new
    @neighborhood = Neighborhood.new
    authorize @neighborhood
  end

  def create
    @neighborhood = Neighborhood.new(neighborhood_params)
    authorize @neighborhood
    if @neighborhood.save
      redirect_to @neighborhood, notice: "Neighborhood created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @neighborhood
  end

  def update
    authorize @neighborhood
    if @neighborhood.update(neighborhood_params)
      redirect_to @neighborhood, notice: "Neighborhood updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @neighborhood
    @neighborhood.destroy
    redirect_to neighborhoods_path, notice: "Neighborhood deleted.", status: :see_other
  end

  private

  def set_neighborhood
    @neighborhood = Neighborhood.find(params[:id])
  end

  def neighborhood_params
    params.require(:neighborhood).permit(:name, :city)
  end
end
