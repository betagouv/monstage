Rails.application.routes.draw do
  devise_for :users, controllers: {
      registrations: 'users/registrations'
  }
  resources :internship_offers

  root to: "internship_offers#index"
end
