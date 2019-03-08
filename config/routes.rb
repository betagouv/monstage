Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'users/registrations'
  }
  resources :internship_offers
  resources :class_rooms, only: [:new, :create, :edit, :update]

  get 'account/edit', to: 'account#edit'
  patch 'account', to: 'account#update'
  get 'account', to: 'account#show'

  root to: "internship_offers#index"
end
