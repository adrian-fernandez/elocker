Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: :update

  namespace :admin do
    resources :companies, only: :index
    resources :teams, only: :index
    resources :users, only: [:index, :show]
    resources :lockers, only: [:index, :show] do
      member do
        post :open
        post :close
      end
    end
  end

  resources :lockers, only: [:index, :show] do
    member do
      post :open
      post :close
    end
  end

  root "home#index"
end
