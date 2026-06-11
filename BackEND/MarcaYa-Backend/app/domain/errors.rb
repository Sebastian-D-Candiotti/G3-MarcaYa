# frozen_string_literal: true

module Domain
  module Errors
    class ValidacionError < StandardError; end
    class UsuarioNoEncontradoError < StandardError; end
    class CredencialesInvalidasError < StandardError; end
    class UsuarioInactivoError < StandardError; end
    class CuentaPendienteVerificacionError < StandardError; end
    class CodigoVerificacionInvalidoError < StandardError; end
    class CodigoVerificacionVencidoError < StandardError; end
    class CodigoVerificacionUsadoError < StandardError; end
    class CorreoVerificacionNoEnviadoError < StandardError; end
    class SolicitudNoEncontradaError < StandardError; end
    class TransicionEstadoInvalidaError < StandardError; end
    class ObraNoEncontradaError < StandardError; end
    class EmpresaNoEncontradaError < StandardError; end
    class PuntuacionInvalidaError < ValidacionError; end
    class ParadaNoEncontradaError < StandardError; end
    class AsistenciaNoEncontradaError < StandardError
      def initialize(mensaje = "Registro de asistencia no encontrado")
        super
      end
    end
    class EntradaActivaExistenteError < ValidacionError; end
    class EmpleadoNoAsignadoParadaError < ValidacionError; end
    class ParadaInactivaError < ValidacionError; end
    class CodigoInvalidoError < StandardError; end
    class CodigoExpiradoError < StandardError; end
    class TokenRecuperacionInvalidoError < StandardError; end
  end
end

