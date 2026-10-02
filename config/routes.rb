Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: :update

  namespace :admin do
    resources :companies, only: :index
    resources :teams, only: :index
    resources :users, only: :index
    resources :lockers, only: [:index, :show]
  end

  resources :lockers, only: [:index, :show]

  root "home#index"
end
