Rails.application.routes.draw do
  devise_for :users
  resources :internship_offers

  root to: "internship_offers#index"
end
