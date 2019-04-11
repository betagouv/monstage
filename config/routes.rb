Rails.application.routes.draw do

  devise_for :users, controllers: {
      registrations: 'users/registrations',
      sessions: 'users/sessions'
  }

  devise_scope :user do
    get 'users/choose_profile' => 'users/registrations#choose_profile'
  end

  resources :internship_offers, only: [:index, :show] do
    resources :internship_applications, only: [:create, :update, :index]
  end

  namespace :dashboard, path: "dashboard" do
    resources :schools, only: [:index, :edit, :update] do
      resources :users, only: [:destroy, :update, :index], module: 'schools'
      resources :class_rooms, only: [:index, :new, :create, :edit, :update, :show], module: 'schools' do
        resources :students, only: [:show, :update], module: 'class_rooms'
      end
    end
    resources :internship_offers do
      resources :internship_applications, only: [:update, :index], module: 'internship_offers'
    end
  end

  resources :users, only: [:edit, :update]

  get '/dashboard', to: 'dashboard#index'
  get 'account', to: 'users#edit'
  patch 'account', to: 'users#update'

  root to: "pages#home"
end
