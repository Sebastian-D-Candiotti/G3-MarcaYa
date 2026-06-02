# frozen_string_literal: true

module Application
  module Facades
    # Implements Ports::Driving::IGestionarSolicitud
    class SolicitudFacade
      def initialize(solicitud_repo:, asignacion_repo:, obra_repo:)
        @solicitud_repo = solicitud_repo
        @asignacion_repo = asignacion_repo
        @obra_repo = obra_repo
      end

      def listar
        UseCases::Solicitudes::ListarSolicitudes.new(solicitud_repo: @solicitud_repo).ejecutar
      end

      def crear(empleado_id:, empresa_id:)
        UseCases::Solicitudes::CrearSolicitud.new(
          solicitud_repo: @solicitud_repo,
          asignacion_repo: @asignacion_repo,
          obra_repo: @obra_repo
        ).ejecutar(empleado_id: empleado_id, empresa_id: empresa_id)
      end

      def aceptar(id:, obra_id:)
        solicitud = UseCases::Solicitudes::AceptarSolicitud.new(solicitud_repo: @solicitud_repo).ejecutar(id: id)

        UseCases::Asignaciones::CrearAsignacion.new(
          asignacion_repo: @asignacion_repo,
          obra_repo: @obra_repo
        ).ejecutar(
          empleado_id: solicitud.empleado_id,
          obra_id: obra_id,
          empresa_id: solicitud.empresa_id
        )

        solicitud
      end

      def rechazar(id:)
        UseCases::Solicitudes::RechazarSolicitud.new(solicitud_repo: @solicitud_repo).ejecutar(id: id)
      end
    end
  end
end
