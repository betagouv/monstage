Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'users/registrations',
      sessions: 'users/sessions'
  }
  devise_scope :user do
    get 'users/choose_profile' => 'users/registrations#choose_profile'
  end

  resources :internship_offers do
    resources :internship_applications, only: [:create, :update, :index]
  end

  resources :schools, only: [:edit, :update, :index] do
    resources :class_rooms, only: [:new, :create, :edit, :update], module: 'schools'
    resources :users, only: [:destroy, :update], module: 'schools'
  end

  resources :users, only: [:edit, :update]

  get 'account', to: 'users#edit'
  patch 'account', to: 'users#update'

  root to: "pages#home"
end
