Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do

      # AUTH
      post "auth/login",    to: "auth#login"
      post "auth/registro", to: "auth#registro"

      # OBRAS (with nested paradas)
      resources :obras do
        member do
          get :paradas, to: "obras#index_paradas"
          post :paradas, to: "obras#create_parada"
        end
      end

      # PARADAS
      resources :paradas, only: [:show, :update, :destroy] do
        member do
          get :empleados, to: "paradas#index_empleados"
          post :empleados, to: "paradas#asignar_empleado"
          delete "empleados/:empleado_id", to: "paradas#desasignar_empleado"
        end
      end

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

      # ASISTENCIA
      namespace :asistencia do
        post 'marcar-entrada', to: 'asistencias#marcar_entrada'
        post 'marcar-salida', to: 'asistencias#marcar_salida'
        get 'historial', to: 'asistencias#historial_personal'
        get 'historial/:empleado_id', to: 'asistencias#historial_empleado'
        get 'tiempo-real', to: 'asistencias#tiempo_real'
        get 'tiempo-real/:parada_id', to: 'asistencias#tiempo_real_parada'
      end

    end
  end

end
