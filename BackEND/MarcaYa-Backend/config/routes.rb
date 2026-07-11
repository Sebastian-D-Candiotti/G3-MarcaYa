Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do

      # AUTH
      post "auth/login",         to: "auth#login"
      post "auth/registro",      to: "auth#registro"
      post "auth/verificar-otp", to: "auth#verificar_otp"

      # SUNAT
      get  "sunat/empresas",          to: "sunat#index"
      get  "sunat/consulta",          to: "sunat#consulta"
      post "sunat/enviar-codigo",     to: "sunat#enviar_codigo"
      get  "sunat/validar-ruc-unico", to: "sunat#validar_ruc_unico"

      # PERFIL (current user profile)
      get  "perfil", to: "perfil#show"
      put  "perfil", to: "perfil#update"

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
      put   "usuarios/:id/aprobar",    to: "usuarios#aprobar"

      # US-NUEVA-13: Activación de empresa vía enlace en correo electrónico
      get   "usuarios/:id/activar-cuenta", to: "usuarios#activar_cuenta"

      resources :usuarios, only: [:index]

      # SOLICITUDES
      # IMPORTANT: mis-solicitudes must come before resources block to avoid :id param match
      get "solicitudes/mis-solicitudes", to: "solicitudes#mis_solicitudes"
      get "solicitudes/:id",            to: "solicitudes#show"
      put "solicitudes/:id/aceptar",    to: "solicitudes#aceptar"
      put "solicitudes/:id/rechazar",   to: "solicitudes#rechazar"

      resources :solicitudes, only: [:index, :create]

      # EMPLEADOS
      get "empleados/:id/obras",
          to: "solicitudes#obras_empleado"

      get "empleados/:id/historial_solicitudes",
          to: "solicitudes#historial_empleado"

      resources :empleados do
        collection do
          get :actuales
        end
        member do
          put :desactivar
          get :asistencias
          get :paradas
        end
      end

      # VALORACIONES
      post   "valoraciones", to: "valoraciones#crear"
      get    "valoraciones/:usuario_id", to: "valoraciones#listar"
      get    "valoraciones/:usuario_id/promedio", to: "valoraciones#promedio"

      # ASISTENCIA
      # NOTA: se usan rutas directas (no namespace) porque el controlador
      # es Api::V1::AsistenciasController, no Api::V1::Asistencia::AsistenciasController
      post 'asistencia/marcar-entrada', to: 'asistencias#marcar_entrada'
      post 'asistencia/marcar-salida', to: 'asistencias#marcar_salida'
      get 'asistencia/historial', to: 'asistencias#historial_personal'
      get 'asistencia/historial/:empleado_id', to: 'asistencias#historial_empleado'
      get 'asistencia/tiempo-real', to: 'asistencias#tiempo_real'
      get 'asistencia/tiempo-real/:parada_id', to: 'asistencias#tiempo_real_parada'

      # REPORTES
      namespace :reportes do
        get "asistencia", to: "reportes#asistencia"
        post "informe-ia", to: "reportes#informe_ia"  # US-NUEVA-06: Informe ejecutivo con IA
      end

      # CRONOGRAMA DE PAGOS
      get  'cronograma',              to: 'cronograma#index'
      get  'cronograma/empresa',      to: 'cronograma#index_empresa'
      post 'cronograma/generar',      to: 'cronograma#generar'
      post 'cronograma/sincronizar',  to: 'cronograma#sincronizar'
      get  'cronograma/:id',          to: 'cronograma#show'

    end
  end
end
