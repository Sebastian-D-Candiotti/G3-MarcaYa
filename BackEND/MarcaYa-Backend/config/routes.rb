Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      # Auth
      post "auth/login",    to: "auth#login"
      post "auth/registro", to: "auth#registro"
      post "auth/logout",   to: "auth#logout"

      # Perfil
      get  "perfil",      to: "perfil#show"
      put  "perfil",      to: "perfil#update"
      get  "perfil/:id",  to: "perfil#show_by_id"
    end
  end
end
