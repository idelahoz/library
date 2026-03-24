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
    end
  end
end
