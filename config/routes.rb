Rails.application.routes.draw do
  resources :internship_offers

  root to: "internship_offers#index"
end
