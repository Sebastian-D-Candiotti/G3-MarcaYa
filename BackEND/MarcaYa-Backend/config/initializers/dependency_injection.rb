# frozen_string_literal: true

# Dependency Injection configuration for Hexagonal Architecture.
# Uses lazy initialization — no autoloaded constants are resolved at boot time.
# Controllers access dependencies via Rails.configuration.di.<facade>.

module DependencyContainer
  class << self
    def auth_facade
      @auth_facade ||= Application::Facades::AuthFacade.new(
        usuario_repo: repos[:usuario],
        empleado_repo: repos[:empleado],
        empresa_repo: repos[:empresa],
        bcrypt_service: Infrastructure::Services::BcryptPasswordService,
        jwt_service: Infrastructure::Services::JwtTokenService,
        verification_code_service: Infrastructure::Services::VerificationCodeService,
        verification_mailer: VerificacionCuentaMailer
      )
    end

    def usuario_facade
      @usuario_facade ||= Application::Facades::UsuarioFacade.new(
        usuario_repo: repos[:usuario]
      )
    end

    def obra_facade
      @obra_facade ||= Application::Facades::ObraFacade.new(
        obra_repo: repos[:obra]
      )
    end

    def solicitud_facade
      @solicitud_facade ||= Application::Facades::SolicitudFacade.new(
        solicitud_repo: repos[:solicitud],
        asignacion_repo: repos[:asignacion],
        obra_repo: repos[:obra]
      )
    end

    def empleado_facade
      @empleado_facade ||= Application::Facades::EmpleadoFacade.new(
        empleado_repo: repos[:empleado],
        obra_repo: repos[:obra],
        asignacion_repo: repos[:asignacion]
      )
    end

    def parada_facade
      @parada_facade ||= Application::Facades::ParadaFacade.new(
        parada_repo: repos[:parada],
        empleado_parada_repo: repos[:empleado_parada],
        obra_repo: repos[:obra],
        empleado_repo: repos[:empleado],
        asignacion_repo: repos[:asignacion]
      )
    end

    def valoracion_facade
      @valoracion_facade ||= Application::Facades::ValoracionFacade.new(
        valoracion_repo: repos[:valoracion],
        empleado_repo: repos[:empleado]
      )
    end

    def asistencia_facade
      @asistencia_facade ||= Application::Facades::AsistenciaFacade.new(
        asistencia_repo: repos[:asistencia],
        empleado_repo: repos[:empleado],
        parada_repo: repos[:parada],
        empleado_parada_repo: repos[:empleado_parada],
        gps_service: Domain::Services::GpsValidationService
      )
    end

    def repos
      @repos ||= {
        usuario: Infrastructure::Repositories::ArUsuarioRepository.new,
        empleado: Infrastructure::Repositories::ArEmpleadoRepository.new,
        empresa: Infrastructure::Repositories::ArEmpresaRepository.new,
        obra: Infrastructure::Repositories::ArObraRepository.new,
        solicitud: Infrastructure::Repositories::ArSolicitudRepository.new,
        asignacion: Infrastructure::Repositories::ArAsignacionRepository.new,
        valoracion: Infrastructure::Repositories::ArValoracionRepository.new,
        parada: Infrastructure::Repositories::ArParadaRepository.new,
        empleado_parada: Infrastructure::Repositories::ArEmpleadoParadaRepository.new,
        asistencia: Infrastructure::Repositories::ArAsistenciaRepository.new
      }.freeze
    end
  end
end

# Wire the container into Rails.configuration.
# This does NOT resolve any constants — it's just a reference assignment.
Rails.configuration.di = DependencyContainer
