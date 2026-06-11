# frozen_string_literal: true

module Domain
  module Entities
    class SunatEmpresa
      attr_reader :ruc, :razon_social, :correo_oficial

      def initialize(ruc:, razon_social:, correo_oficial:)
        @ruc = ruc
        @razon_social = razon_social
        @correo_oficial = correo_oficial
      end
    end
  end
end
