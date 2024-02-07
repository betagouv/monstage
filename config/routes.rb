# frozen_string_literal: true
require 'sidekiq/web'

Rails.application.routes.draw do
  # ------------------ SCOPE START ------------------
  scope(path_names: { new: 'nouveau', edit: 'modification' }) do
    authenticate :user, lambda { |u| u.is_a?(Users::God) } do
      mount Sidekiq::Web => '/sidekiq'
      match "/split" => Split::Dashboard,
          anchor: false,
          via: [:get, :post, :delete]
    end

    mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
    mount ActionCable.server => '/cable'

    devise_for :users, path: 'utilisateurs', path_names: {
      sign_in: 'connexion',
      sign_out: 'deconnexion',
      sign_up: 'inscription',
      password: 'mot-de-passe'
    }, controllers: {
      confirmations: 'users/confirmations',
      registrations: 'users/registrations',
      sessions: 'users/sessions',
      passwords: 'users/passwords'
    }

    devise_scope :user do
      get 'utilisateurs/choisir_profil', to: 'users/registrations#choose_profile', as: 'users_choose_profile'
      get '/utilisateurs/inscriptions/en-attente', to: 'users/registrations#confirmation_standby', as: 'users_registrations_standby'
      get '/utilisateurs/inscriptions/referent-en-attente', to: 'users/registrations#statistician_standby', as: 'statistician_standby'
      # get '/utilisateurs/inscriptions/en-attente-telephone', to: 'users/registrations#confirmation_phone_standby', as: 'users_registrations_phone_standby'
      post '/utilisateurs/inscriptions/validation-telephone', to: 'users/registrations#phone_validation', as: 'phone_validation'
      get '/utilisateurs/mot-de-passe/modification-par-telephone', to: 'users/passwords#edit_by_phone', as: 'phone_edit_password'
      put '/utilisateurs/mot-de-passe/update_by_phone', to: 'users/passwords#update_by_phone', as: 'phone_update_password'
      get '/utilisateurs/mot-de-passe/initialisation', to: 'users/passwords#set_up', as: 'set_up_password'
    end

    resources :identities, path: 'identites', only: %i[new create]
    resources :url_shrinkers, path: 'c', only: %i[] do
      get :o, on: :member
    end
    resources :schools, path: 'ecoles',only: %i[new create ]

    resources :internship_offer_keywords, only: [] do
      collection do
        post :search
      end
    end

    resources :internship_offers, path: 'offres-de-stage', only: %i[index show] do
      collection do
        get :search, path: 'recherche'
      end
      resources :internship_applications, path: 'candidatures', only: %i[new create index show update] do
        member do
          get :edit_transfer
          post :transfer
          get :completed
        end
      end
      member do
        post :apply_count
      end
    end
    resources :favorites, only: %i[create destroy index]

    namespace :api, path: 'api' do
      resources :internship_offers, only: %i[create update destroy index] do
        collection do
          get :search
        end
      end
      resources :schools, only: [] do
        collection do
          post :nearby
          post :search
        end
      end
      resources :sectors, only: :index
    end
    # ------------------ DASHBOARD START ------------------
    namespace :dashboard, path: 'tableau-de-bord' do
      resources :team_member_invitations, path: 'invitation-equipes', only: %i[create index new destroy] do
        patch :join, to: 'team_member_invitations#join', on: :member
      end
      resources :internship_agreements,  path: 'conventions-de-stage', except: %i[destroy]
      resources :users, path: 'signatures', only: %i[update], module: 'group_signing' do
        member do
          post 'start_signing'
          post 'reset_phone_number'
          post 'resend_sms_code'
          post 'signature_code_validate'
          post 'handwrite_sign'
        end
      end

      resources :schools, path: 'ecoles', only: %i[index edit update show] do
        resources :invitations, only: %i[new create index destroy], module: 'schools'
        get '/resend_invitation', to: 'schools/invitations#resend_invitation', module: 'schools'
        resources :users, path: 'utilisateurs', only: %i[destroy update index], module: 'schools'
        resources :internship_agreement_presets, only: %i[edit update],  module: 'schools'

        resources :class_rooms, path: 'classes', only: %i[index new create edit update show destroy], module: 'schools' do
          resources :students, path: 'eleves', only: %i[update index new create], module: 'class_rooms'
        end
        put '/update_students_by_group', to: 'schools/students#update_by_group', module: 'schools'
        get '/information', to: 'schools#information', module: 'schools'
      end

      resources :internship_offer_areas, path: 'espaces', except: %i[show] do
        get :filter_by_area, on: :member
        resources :area_notifications, path: 'notifications-d-espace', only: %i[edit update index], module: 'internship_offer_areas' do
          patch :flip , on: :member
        end
      end

      resources :internship_offers, path: 'offres-de-stage', except: %i[show] do
        resources :internship_applications, path: 'candidatures', only: %i[update index show], module: 'internship_offers' do
          patch :set_to_read, on: :member
          get :school_details, on: :member
        end
        post :publish, on: :member
        post :remove, on: :member
        patch :republish, to: 'internship_offers#republish', on: :member
      end

      namespace :stepper, path: 'etapes' do
        resources :organisations, only: %i[create new edit update]
        resources :internship_offer_infos, path: 'offre-de-stage-infos', only: %i[create new edit update]
        resources :hosting_infos, path: 'accueil-infos', only: %i[create new edit update]
        resources :practical_infos, path: 'infos-pratiques', only: %i[create new edit update]
        resources :tutors, path: 'tuteurs', only: %i[create new]
      end

      namespace :students, path: '/:student_id/' do
        resources :internship_applications, path: 'candidatures', only: %i[index show edit update] do
          post :resend_application, on: :member
        end
      end

      get 'candidatures', to: 'internship_offers/internship_applications#user_internship_applications'
    end
    # ------------------ DASHBOARD END ------------------
  end
  # ------------------ SCOPE END ------------------

  namespace :reporting, path: 'reporting' do
    get '/dashboards', to: 'dashboards#index'

    get '/schools', to: 'schools#index'
    get '/employers_internship_offers', to: 'internship_offers#employers_offers'
    get 'internship_offers', to: 'internship_offers#index'
    get 'operators', to: 'operators#index'
    put 'operators', to: 'operators#update'
  end

  get 'api_address_proxy/search', to: 'api_address_proxy#search', as: :api_address_proxy_search
  get 'api_sirene_proxy/search', to: 'api_sirene_proxy#search', as: :api_sirene_proxy_search
  get 'api_entreprise_proxy/search', to: 'api_entreprise_proxy#search', as: :api_entreprise_proxy_search

  get 'mon-compte(/:section)', to: 'users#edit', as: 'account'
  patch 'mon-compte', to: 'users#update'
  patch 'account_password', to: 'users#update_password'
  patch 'answer_survey', to: 'users#answer_survey'

  get '/accessibilite', to: 'pages#accessibilite'
  get '/conditions-d-utilisation', to: 'pages#conditions_d_utilisation'
  # TODO
  # get '/conditions-d-utilisation-service-signature', to: 'pages#conditions_utilisation_service_signature',
  get '/contact', to: 'pages#contact', as: 'contact'
  get '/documents-utiles', to: 'pages#documents_utiles'
  get '/javascript-required', to: 'pages#javascript_required'
  get '/mentions-legales', to: 'pages#mentions_legales'
  get '/les-10-commandements-d-une-bonne-offre', to: 'pages#les_10_commandements_d_une_bonne_offre'
  get '/operators', to: 'pages#operators'
  get '/politique-de-confidentialite', to: 'pages#politique_de_confidentialite'
  get '/statistiques', to: 'pages#statistiques'
  post '/newsletter', to: 'newsletter#subscribe'
  get '/inscription-permanence', to: 'pages#register_to_webinar'
  # TODO
  # To be removed after june 2023
  get '/register_to_webinar', to: 'pages#register_to_webinar'
  get '/eleves', to: 'pages#student_landing'
  get '/professionnels', to: 'pages#pro_landing'
  get '/equipe-pedagogique', to: 'pages#school_management_landing'
  get '/referents', to: 'pages#statistician_landing'

  # Redirects
  get '/dashboard/internship_offers/:id', to: redirect('/internship_offers/%{id}', status: 302)

  root to: 'pages#home'

  get '/404', to: 'errors#not_found'
  get '/422', to: 'errors#unacceptable'
  get '/500', to: 'errors#internal_error'
  get '/flyer_2022', to: 'pages#flyer'
end
