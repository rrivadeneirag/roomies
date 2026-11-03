Rails.application.routes.draw do
  root "pages#home"
  get "search", to: "pages#search"

  # Authentication (Rails 8 native generator)
  resource :session
  resources :passwords, param: :token
  resource :registration, only: [:new, :create]   # sign up
  resource :profile, only: [:show, :edit, :update]

  resources :properties do
    resources :listings, only: [:new, :create]
  end

  resources :listings, only: [:index, :show, :edit, :update, :destroy] do
    member do
      patch :publish
      patch :withdraw
      patch :mark_rented
    end
    resources :applications, only: [:create]
    resources :reports, only: [:create]
  end

  resources :applications, only: [:index, :show, :destroy] do
    member do
      patch :shortlist
      patch :reject
      patch :accept
      patch :withdraw
    end
    resources :visits, only: [:create]
  end

  resources :visits, only: [] do
    member do
      patch :confirm
      patch :cancel
      patch :complete
      patch :reschedule
    end
    resources :reviews, only: [:create]
  end

  # Moderator reports inbox
  resources :reports, only: [:index, :update]

  resources :neighborhoods
  resources :amenities, except: [:show]


# Public JSON API
namespace :api do
  namespace :v1 do
    resources :listings, only: [:index, :show]
  end
end

  get "up" => "rails/health#show", as: :rails_health_check
end
