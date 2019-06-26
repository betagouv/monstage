# frozen_string_literal: true

Rails.application.routes.draw do
  resources :feedbacks
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  devise_scope :user do
    get 'users/choose_profile' => 'users/registrations#choose_profile'
  end

  resources :internship_offers, only: %i[index show] do
    resources :internship_applications, only: %i[create index show update]
  end

  namespace :dashboard, path: 'dashboard' do
    resources :schools, only: %i[index edit update] do
      resources :users, only: %i[destroy update index], module: 'schools'
      resources :class_rooms, only: %i[index new create edit update show], module: 'schools' do
        resources :students, only: %i[show update], module: 'class_rooms'
      end
    end

    resources :internship_offers do
      resources :internship_applications, only: %i[update index], module: 'internship_offers'
    end

    namespace :students, path: '/:student_id/' do
      resources :internship_applications, only: %i[index show]
    end
  end

  get '/dashboard', to: 'dashboard#index'

  get 'account(/:section)', to: 'users#edit', as: 'account'
  patch 'account', to: 'users#update'

  get '/les-10-commandements-d-une-bonne-offre', to: 'pages#les_10_commandements_d_une_bonne_offre'
  get '/exemple-offre-ideale-ministere', to: 'pages#exemple_offre_ideale_ministere'
  get '/exemple-offre-ideale-sport', to: 'pages#exemple_offre_ideale_sport'
  get '/documents-utiles', to: 'pages#documents_utiles'
  get '/qui-sommes-nous', to: 'pages#qui_sommes_nous'
  get '/partenaires', to: 'pages#partenaires'
  get '/mentions-legales', to: 'pages#mentions_legales'
  get '/conditions-d-utilisation', to: 'pages#conditions_d_utilisation'
  get '/faq', to: 'pages#faq'
  get '/accessibilite', to: 'pages#accessibilite'
  get '/statistiques', to: 'pages#statistiques'
  get '/operators', to: 'pages#operators'

  match '/admin/delayed_job' => DelayedJobWeb, :anchor => false, :via => %i[get post]

  root to: 'pages#home'
end
