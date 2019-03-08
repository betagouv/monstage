Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'users/registrations'
  }
  resources :internship_offers


  resources :schools, only: [:edit, :update] do
    resources :class_rooms, only: [:new, :create, :edit, :update]
  end

  get 'account', to: 'account#show'
  get 'account/edit', to: 'account#edit'
  patch 'account', to: 'account#update'

  root to: "internship_offers#index"
end
