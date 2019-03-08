Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'users/registrations'
  }
  resources :internship_offers
  resources :school_internship_offers, only: [:edit, :update]
  resources :class_rooms, only: [:new, :create, :edit, :update]

  get 'account', to: 'accounts#index'

  root to: "internship_offers#index"
end
