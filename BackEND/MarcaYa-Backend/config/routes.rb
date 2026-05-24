Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      post "auth/login",    to: "auth#login"
      post "auth/registro", to: "auth#registro"
    end
  end
end
