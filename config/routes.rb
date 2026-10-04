Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resource :session, only: :update
  get "switcher/users", to: "sessions#switcher_users", as: :switcher_users

  namespace :admin do
    resources :companies, only: :index
    resources :teams, only: :index
    resources :users, only: [:index, :show]
    resources :physical_devices, only: [:index, :show]
    resources :lockers, only: [:index, :show] do
      member do
        post :open
        post :close
        post :force_open
        post :force_close
        get  :transfer, action: :transfer_form
        post :transfer
      end
    end
  end

  resources :lockers, only: [:index, :show] do
    member do
      post :open
      post :close
      post :force_open
      post :force_close
    end
  end

  get "activity", to: "activity#index", as: :activity

  root "home#index"
end
