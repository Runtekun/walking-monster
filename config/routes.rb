Rails.application.routes.draw do
  get "dashboard/show"
  get "static_pages/contact"
  get "static_pages/terms"
  get "static_pages/privacy"
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  devise_scope :user do
    get "users/profile", to: "devise/registrations#show", as: :user_profile
  end

  authenticated :user do
    root to: "dashboard#show", as: :authenticated_root
  end

  unauthenticated do
    root "top_pages#top"
  end

  resources :posts, only: %i[index new create show edit destroy update] do
    resources :comments, only: %i[create edit destroy], shallow: true
  end

  resources :destinations, only: %i[index create show destroy] do
    member do
      post :complete_walk
      get :walking
    end
  end

  resources :user_monsters, only: %i[index new create]

  namespace :users do
    get "ranking", to: "ranking#index"
  end

  get "contact", to: "static_pages#contact", as: :contact
  get "terms", to: "static_pages#terms", as: :terms
  get "privacy", to: "static_pages#privacy", as: :privacy

  require "sidekiq/web"
  mount Sidekiq::Web => "/sidekiq"

  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"
end
