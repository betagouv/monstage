Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'users/registrations'
  }
  devise_scope :user do
    get 'users/choose_profile' => 'users/registrations#choose_profile'
  end

  resources :internship_offers
  resources :internship_applications, only: [:create]

  resources :schools, only: [:edit, :update, :index] do
    resources :class_rooms, only: [:new, :create, :edit, :update]
  end

  get 'account', to: 'account#show'
  get 'account/edit', to: 'account#edit'
  patch 'account', to: 'account#update'

  root to: "internship_offers#index"
end
