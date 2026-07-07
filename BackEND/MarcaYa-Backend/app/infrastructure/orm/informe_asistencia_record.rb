# frozen_string_literal: true

module Infrastructure
  module Orm
    class InformeAsistenciaRecord < ActiveRecord::Base
      self.table_name = "informe_asistencias"

      TIPOS_PERIODO = %w[DIARIO SEMANAL MENSUAL].freeze
      ESTADOS = %w[BORRADOR CERRADO].freeze

      belongs_to :empresa, class_name: "Infrastructure::Orm::EmpresaRecord",
                           foreign_key: :empresa_id
      belongs_to :generado_por, class_name: "Infrastructure::Orm::UsuarioRecord",
                                foreign_key: :generado_por_id

      validates :tipo_periodo, inclusion: { in: TIPOS_PERIODO }
      validates :estado, inclusion: { in: ESTADOS }
      validates :fecha_inicio, :fecha_fin, :fecha_generacion, :snapshot, :checksum, presence: true
      validate :fecha_fin_no_antecede_inicio

      before_update :impedir_modificar_cerrado
      before_destroy :impedir_eliminar_cerrado

      def cerrado?
        estado == "CERRADO"
      end

      private

      def fecha_fin_no_antecede_inicio
        return if fecha_inicio.blank? || fecha_fin.blank? || fecha_fin >= fecha_inicio

        errors.add(:fecha_fin, "no puede ser anterior a fecha_inicio")
      end

      def impedir_modificar_cerrado
        return unless estado_was == "CERRADO"

        errors.add(:base, "Un informe cerrado es inmutable")
        throw :abort
      end

      def impedir_eliminar_cerrado
        return unless cerrado?

        errors.add(:base, "Un informe cerrado no puede eliminarse")
        throw :abort
      end
    end
  end
end
