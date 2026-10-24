class UsersController < ApplicationController
  # Sets which user we are acting as (no login yet — Assignment 4).
  def switch
    session[:user_id] = params[:user_id]
    redirect_back fallback_location: root_path
  end
end
