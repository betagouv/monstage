# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  authenticate :user, lambda { |u| u.is_a?(Users::God) } do
    mount Sidekiq::Web => '/sidekiq'
    match "/split" => Split::Dashboard,
        anchor: false,
        via: [:get, :post, :delete]
  end

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount ActionCable.server => '/cable'

  devise_for :users, controllers: {
    confirmations: 'users/confirmations',
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords'
  }

  devise_scope :user do
    get 'users/choose_profile', to: 'users/registrations#choose_profile'
    get '/users/registrations/standby', to: 'users/registrations#confirmation_standby'
    get '/users/registrations/phone_standby', to: 'users/registrations#confirmation_phone_standby'
    post '/users/registrations/phone_validation', to: 'users/registrations#phone_validation', as: 'phone_validation'
    get '/users/password/edit_by_phone', to: 'users/passwords#edit_by_phone', as: 'phone_edit_password'
    put '/users/password/update_by_phone', to: 'users/passwords#update_by_phone', as: 'phone_update_password'
  end
  
  resources :identities, only: %i[new create edit update]

  resources :internship_offer_keywords, only: [] do
    collection do
      post :search
    end
  end

  resources :internship_offers, only: %i[index show] do
    collection do
      get :search
    end
    resources :internship_applications, only: %i[new create index show update]
  end

  namespace :api, path: 'api' do
    resources :internship_offers, only: %i[create update destroy]
    resources :schools, only: [] do
      collection do
        post :nearby
        post :search
      end
    end
  end

  namespace :dashboard, path: 'dashboard' do
    # resources :support_tickets, only: %i[new create] not used anymore since remote internships are off
    resources :internship_agreements,  except: %i[destroy]
    resources :internship_applications, only: %i[index]

    resources :schools, only: %i[index edit update show] do
      resources :users, only: %i[destroy update index], module: 'schools'


      resources :internship_applications, only: %i[index], module: 'schools'
      resources :internship_agreement_presets, only: %i[edit update],  module: 'schools'

      resources :class_rooms, only: %i[index new create edit update show destroy], module: 'schools' do
        resources :students, only: %i[show update], module: 'class_rooms'
      end
      put '/update_students_by_group', to: 'schools/students#update_by_group', module: 'schools'
    end

    resources :internship_offers, except: %i[show] do
      resources :internship_applications, only: %i[update index], module: 'internship_offers'
    end

    namespace :stepper do
      resources :organisations,          only: %i[create new edit update]
      resources :internship_offer_infos, only: %i[create new edit update]
      resources :tutors,                 only: %i[create new]
    end

    namespace :students, path: '/:student_id/' do
      resources :internship_applications, only: %i[index show]
    end
  end

  namespace :reporting, path: 'reporting' do
    get '/dashboards', to: 'dashboards#index'
    get '/import_data', to: 'dashboards#import_data'
    post '/dashboards/refresh', to: 'dashboards#refresh'

    get '/schools', to: 'schools#index'
    get '/employers_internship_offers', to: 'internship_offers#employers_offers'
    get 'internship_offers', to: 'internship_offers#index'
    get 'operators', to: 'operators#index'
    put 'operators', to: 'operators#update'
  end

  get 'api_address_proxy/search', to: 'api_address_proxy#search', as: :api_address_proxy_search
  get 'api_sirene_proxy/search', to: 'api_sirene_proxy#search', as: :api_sirene_proxy_search

  get 'account(/:section)', to: 'users#edit', as: 'account'
  patch 'account', to: 'users#update'
  patch 'account_password', to: 'users#update_password'

  get '/reset-cache', to: 'pages#reset_cache', as: 'reset_cache'
  get '/accessibilite', to: 'pages#accessibilite'
  get '/conditions-d-utilisation', to: 'pages#conditions_d_utilisation'
  get '/conditions-d-utilisation-service-signature', to: 'pages#conditions_utilisation_service_signature'
  get '/contact', to: 'pages#contact'
  get '/exemple-offre-ideale-ministere', to: 'pages#exemple_offre_ideale_ministere'
  get '/exemple-offre-ideale-sport', to: 'pages#exemple_offre_ideale_sport'
  get '/documents-utiles', to: 'pages#documents_utiles'
  get '/javascript-required', to: 'pages#javascript_required'
  get '/mentions-legales', to: 'pages#mentions_legales'
  get '/les-10-commandements-d-une-bonne-offre', to: 'pages#les_10_commandements_d_une_bonne_offre'
  get '/operators', to: 'pages#operators'
  get '/partenaires', to: 'pages#partenaires'
  get '/politique-de-confidentialite', to: 'pages#politique_de_confidentialite'
  get '/statistiques', to: 'pages#statistiques'

  # Redirects
  get '/dashboard/internship_offers/:id', to: redirect('/internship_offers/%{id}', status: 302)

  root to: 'pages#home'

  get '/404', to: 'errors#not_found'
  get '/422', to: 'errors#unacceptable'
  get '/500', to: 'errors#internal_error'
end
