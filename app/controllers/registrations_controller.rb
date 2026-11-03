class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(registration_params)
    @user.role = :member
    if @user.save
      start_new_session_for @user
      redirect_to root_path, notice: "Welcome to Roomies!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:name, :email_address, :phone, :password, :password_confirmation)
  end
end
