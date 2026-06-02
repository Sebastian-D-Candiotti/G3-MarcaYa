# frozen_string_literal: true

module Ports
  module Driving
    module IGestionarValoracion
      def crear_valoracion(empleado_id:, empresa_id:, puntuacion:, comentario: nil)
        raise NotImplementedError
      end

      def listar_por_empresa(empresa_id:)
        raise NotImplementedError
      end

      def promedio_empresa(empresa_id:)
        raise NotImplementedError
      end
    end
  end
end
