# frozen_string_literal: true

module Domain
  module Errors
    class ValidacionError < StandardError; end
    class UsuarioNoEncontradoError < StandardError; end
    class CredencialesInvalidasError < StandardError; end
    class UsuarioInactivoError < StandardError; end
    class SolicitudNoEncontradaError < StandardError; end
    class TransicionEstadoInvalidaError < StandardError; end
    class ObraNoEncontradaError < StandardError; end
    class PuntuacionInvalidaError < ValidacionError; end
  end
end
