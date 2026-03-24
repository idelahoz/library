Rails.application.routes.draw do
  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Auth
      resource :session, only: %i[create destroy]
      post :register, to: "registrations#create"

      # Current user
      resource :me, only: %i[show], controller: :me

      # Books
      resources :books, only: %i[index create update destroy]

      # Borrowings
      resources :borrowings, only: %i[create]
    end
  end
end
