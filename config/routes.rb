Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'users/registrations'
  }
  resources :internship_offers

  get 'account', to: 'accounts#edit'
  patch 'account', to: 'accounts#update'

  root to: "internship_offers#index"
end
