# frozen_string_literal: true

require "digest"
require "json"

module Application
  module UseCases
    module InformesAsistencia
      class CerrarMes < Base
        def initialize(snapshot_builder: ConstruirSnapshot.new)
          @snapshot_builder = snapshot_builder
        end

        def call(current_user:, params:)
          return Resultado.fail("No autorizado", status: :forbidden) unless %w[empresa admin].include?(current_user&.rol)

          anio = params[:anio].to_i
          mes = params[:mes].to_i
          return Resultado.fail("anio y mes son obligatorios", status: :unprocessable_entity) unless anio.positive? && mes.between?(1, 12)

          fecha_inicio = Date.new(anio, mes, 1)
          fecha_fin = fecha_inicio.end_of_month
          empresa = params[:empresa_id].present? ? empresa_autorizada(current_user, params[:empresa_id]) : empresa_principal(current_user)
          return Resultado.fail("No autorizado para esta empresa", status: :forbidden) unless empresa

          record = nil
          ActiveRecord::Base.transaction do
            existente = Infrastructure::Orm::InformeAsistenciaRecord
                        .lock
                        .where(
                          empresa_id: empresa.id,
                          tipo_periodo: "MENSUAL",
                          fecha_inicio: fecha_inicio,
                          fecha_fin: fecha_fin,
                          estado: "CERRADO"
                        )
                        .first
            raise MesCerradoError if existente

            snapshot = @snapshot_builder.call(
              empresa: empresa,
              tipo_periodo: "MENSUAL",
              fecha_inicio: fecha_inicio,
              fecha_fin: fecha_fin
            )
            checksum = Digest::SHA256.hexdigest(JSON.generate(snapshot))

            record = Infrastructure::Orm::InformeAsistenciaRecord.create!(
              empresa_id: empresa.id,
              tipo_periodo: "MENSUAL",
              fecha_inicio: fecha_inicio,
              fecha_fin: fecha_fin,
              estado: "CERRADO",
              fecha_generacion: Time.current,
              fecha_cierre: Time.current,
              generado_por_id: current_user.id,
              version: 1,
              snapshot: snapshot,
              checksum: checksum
            )
          end

          Resultado.ok(serializar_record(record), status: :created)
        rescue MesCerradoError
          Resultado.fail("El mes ya fue cerrado para esta empresa", status: :conflict)
        rescue Date::Error
          Resultado.fail("anio o mes invalido", status: :unprocessable_entity)
        rescue ActiveRecord::RecordInvalid => e
          Resultado.fail(e.record.errors.full_messages.join(", "), status: :unprocessable_entity)
        end

        class MesCerradoError < StandardError; end
      end
    end
  end
end
