Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do

      # AUTH
      post "auth/login",    to: "auth#login"
      post "auth/registro", to: "auth#registro"

      # OBRAS
      resources :obras

      # USUARIOS
      get   "usuarios/:id",            to: "usuarios#show"
      put   "usuarios/:id",            to: "usuarios#update"
      patch "usuarios/:id/desactivar", to: "usuarios#desactivar"

      resources :usuarios, only: [:index]

      # SOLICITUDES
      resources :solicitudes, only: [:index, :create]

      put "solicitudes/:id/aceptar", to: "solicitudes#aceptar"
      put "solicitudes/:id/rechazar", to: "solicitudes#rechazar"

      # EMPLEADOS
      get "empleados/:id/obras",
          to: "solicitudes#obras_empleado"

      get "empleados/:id/historial_solicitudes",
          to: "solicitudes#historial_empleado"

      resources :empleados do
        collection do
          get :actuales
        end
      end

    end
  end

end