Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'users/registrations'
  }
  resources :internship_offers
  resources :class_rooms, only: [:new, :create]

  root to: "internship_offers#index"
end
