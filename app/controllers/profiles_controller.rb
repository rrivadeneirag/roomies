class ProfilesController < ApplicationController
  before_action :set_user

  def show; end
  def edit; end

  def update
    if @user.update(profile_params)
      redirect_to profile_path, notice: "Profile updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = current_user
  end

  def profile_params
    params.require(:user).permit(:name, :phone, :bio)
  end
end
