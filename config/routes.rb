Rails.application.routes.draw do

  resources :feedbacks
  devise_for :users, controllers: {
      registrations: 'users/registrations',
      sessions: 'users/sessions'
  }

  devise_scope :user do
    get 'users/choose_profile' => 'users/registrations#choose_profile'
  end

  resources :internship_offers, only: [:index, :show] do
    resources :internship_applications, only: [:create, :index, :show, :update]
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

    namespace :students, path: '/:student_id/' do
      resources :internship_applications, only: [:index, :show]
    end
  end

  # resources :users, only: [:edit, :update]
  # resources :curriculum_vitaes, only: [:edit, :update]

  get '/dashboard', to: 'dashboard#index'

  get 'account(/:section)', to: 'users#edit', as: 'account'
  patch 'account', to: 'users#update'

  get '/les-10-commandements-d-une-bonne-offre', to: 'pages#les_10_commandements_d_une_bonne_offre'
  get '/exemple-offre-ideale-ministere', to: 'pages#exemple_offre_ideale_ministere'
  get '/exemple-offre-ideale-sport', to: 'pages#exemple_offre_ideale_sport'

  root to: "pages#home"
end
