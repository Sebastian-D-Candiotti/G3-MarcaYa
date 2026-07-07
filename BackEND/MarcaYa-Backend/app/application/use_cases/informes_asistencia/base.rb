# frozen_string_literal: true

module Application
  module UseCases
    module InformesAsistencia
      class Base
        TIPOS_PERIODO = %w[DIARIO SEMANAL MENSUAL].freeze

        private

        def empresa_autorizada(current_user, empresa_id)
          return nil unless current_user

          if current_user.rol == "admin"
            return Infrastructure::Orm::EmpresaRecord.find_by(id: empresa_id)
          end

          return nil unless current_user.rol == "empresa"

          current_user.empresas.find_by(id: empresa_id)
        end

        def empresa_principal(current_user)
          return nil unless current_user
          return Infrastructure::Orm::EmpresaRecord.first if current_user.rol == "admin"

          current_user.empresas.first
        end

        def parse_fecha(value, nombre)
          Date.parse(value.to_s)
        rescue Date::Error
          raise ArgumentError, "#{nombre} tiene formato invalido"
        end

        def normalizar_tipo(tipo)
          tipo.to_s.upcase
        end

        def validar_tipo!(tipo)
          return if TIPOS_PERIODO.include?(tipo)

          raise ArgumentError, "tipo_periodo debe ser DIARIO, SEMANAL o MENSUAL"
        end

        def validar_rango_por_tipo!(tipo, fecha_inicio, fecha_fin)
          raise ArgumentError, "fecha_fin no puede ser anterior a fecha_inicio" if fecha_fin < fecha_inicio

          case tipo
          when "DIARIO"
            raise ArgumentError, "El informe diario debe cubrir un solo dia" unless fecha_inicio == fecha_fin
          when "SEMANAL"
            raise ArgumentError, "El informe semanal debe cubrir hasta 7 dias" if (fecha_fin - fecha_inicio).to_i > 6
          when "MENSUAL"
            unless fecha_inicio == fecha_inicio.beginning_of_month && fecha_fin == fecha_inicio.end_of_month
              raise ArgumentError, "El informe mensual debe iniciar el primer dia y terminar el ultimo dia del mes"
            end
          end
        end

        def serializar_record(record)
          {
            id: record.id,
            empresa_id: record.empresa_id,
            tipo_periodo: record.tipo_periodo,
            fecha_inicio: record.fecha_inicio,
            fecha_fin: record.fecha_fin,
            estado: record.estado,
            fecha_generacion: record.fecha_generacion,
            fecha_cierre: record.fecha_cierre,
            generado_por_id: record.generado_por_id,
            version: record.version,
            checksum: record.checksum,
            snapshot: record.snapshot,
            created_at: record.created_at,
            updated_at: record.updated_at
          }
        end
      end
    end
  end
end
