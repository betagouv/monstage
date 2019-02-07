Rails.application.routes.draw do
  resource :internship_offers

  root to: "internship_offers#index"
end
