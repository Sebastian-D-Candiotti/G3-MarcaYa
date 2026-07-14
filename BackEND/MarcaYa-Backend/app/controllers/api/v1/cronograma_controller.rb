# frozen_string_literal: true

module Api
  module V1
    class CronogramaController < BaseController
      before_action :require_empleado!, only: [:index]
      before_action :require_empresa_or_admin!, only: [:index_empresa, :generar, :sincronizar]

      # GET /api/v1/cronograma
      # Empleado: ver su propio cronograma de pagos
      def index
        empleado = current_user.empleados.first
        unless empleado
          render json: { error: "No se encontró empleado asociado" }, status: :not_found
          return
        end

        cronogramas = CronogramaDePago.del_empleado(empleado.id)
                                       .includes(:obra)
                                       .order(created_at: :desc)

        render json: cronogramas.map { |c| serialize(c) }
      end

      # GET /api/v1/cronograma/empresa
      # Empresa: ver cronograma de todos sus empleados
      def index_empresa
        empresa = current_user.empresas&.first
        unless empresa
          render json: { error: "No se encontró empresa asociada" }, status: :not_found
          return
        end

        obra_ids = Obra.where(empresa_id: empresa.id).pluck(:id)
        cronogramas = CronogramaDePago.where(obra_id: obra_ids)
                                       .includes(:empleado, :obra)
                                       .order(created_at: :desc)

        render json: cronogramas.map { |c| serialize_empresa(c) }
      end

      # POST /api/v1/cronograma/generar
      # Empresa: generar cronograma para un período
      #
      # Params:
      #   periodo_inicio (date) — inicio del período
      #   periodo_fin    (date) — fin del período
      #   tarifa_hora    (decimal, optional) — tarifa por hora, default 15.00
      def generar
        empresa = current_user.empresas&.first
        unless empresa
          render json: { error: "No se encontró empresa asociada" }, status: :not_found
          return
        end

        periodo_inicio = params[:periodo_inicio]
        periodo_fin    = params[:periodo_fin]

        unless periodo_inicio.present? && periodo_fin.present?
          render json: { error: "Se requiere periodo_inicio y periodo_fin" }, status: :unprocessable_entity
          return
        end

        tarifa = (params[:tarifa_hora] || 15.0).to_f
        periodo_label = "#{periodo_inicio}_#{periodo_fin}"

        obras = Obra.where(empresa_id: empresa.id)
        obra_ids = obras.pluck(:id)

        # Obtener asistencias válidas en el período
        asistencias = ::Infrastructure::Orm::AsistenciaRecord
                        .joins(parada: :obra)
                        .where(obras: { id: obra_ids })
                        .where(tipo_marcacion: "SALIDA", valida_gps: true)
                        .where.not(duracion_jornada: nil)
                        .where(fecha_hora: Time.zone.parse(periodo_inicio).beginning_of_day..Time.zone.parse(periodo_fin).end_of_day)
                        .includes(parada: :obra)

        # Agrupar por empleado + obra
        agrupado = asistencias.group_by { |a| [a.empleado_id, a.parada.obra_id] }

        cronogramas_creados = []

        agrupado.each do |(empleado_id, obra_id), registros|
          # duracion_jornada está en minutos, se convierte a horas
          horas = registros.sum { |r| r.duracion_jornada.to_f / 60.0 }

          cronograma = CronogramaDePago.find_or_initialize_by(
            empleado_id: empleado_id,
            obra_id: obra_id,
            periodo: periodo_label
          )

          cronograma.assign_attributes(
            horas_trabajadas: horas.round(2),
            tarifa_hora: tarifa,
            monto_total: (horas * tarifa).round(2),
            estado: "pendiente"
          )

          cronograma.save!
          cronogramas_creados << cronograma
        end

        render json: {
          mensaje: "Planilla generada exitosamente",
          total_registros: cronogramas_creados.size,
          periodo: periodo_label,
          cronogramas: cronogramas_creados.map { |c| serialize_empresa(c) }
        }, status: :created
      end

      # GET /api/v1/cronograma/:id
      # Autenticado: ver detalle de un cronograma
      def show
        cronograma = CronogramaDePago.includes(:empleado, :obra).find_by(id: params[:id])

        unless cronograma
          render json: { error: "Cronograma no encontrado" }, status: :not_found
          return
        end

        render json: serialize_empresa(cronograma)
      end

      # POST /api/v1/cronograma/sincronizar
      # Empresa: sincronización simulada con sistema contable externo
      #
      # Marca todos los cronogramas aprobados/pendientes como "sincronizado"
      # y simula un log de envío al sistema contable.
      def sincronizar
        empresa = current_user.empresas&.first
        unless empresa
          render json: { error: "No se encontró empresa asociada" }, status: :not_found
          return
        end

        obra_ids = Obra.where(empresa_id: empresa.id).pluck(:id)
        pendientes = CronogramaDePago.where(obra_id: obra_ids)
                                      .where(estado: ["pendiente", "aprobado"])

        total = pendientes.count

        if total.zero?
          render json: {
            mensaje: "No hay registros pendientes para sincronizar",
            total_sincronizados: 0
          }
          return
        end

        # Simulación de sincronización contable
        pendientes.update_all(estado: "sincronizado", updated_at: Time.current)

        Rails.logger.info(
          "[SYNC CONTABLE] Empresa #{empresa.id}: #{total} cronogramas sincronizados " \
          "con sistema contable externo a las #{Time.current.iso8601}"
        )

        render json: {
          mensaje: "Sincronización completada exitosamente",
          total_sincronizados: total,
          fecha_sincronizacion: Time.current.iso8601
        }
      end

      private

      def serialize(cronograma)
        {
          id: cronograma.id,
          periodo: cronograma.periodo,
          horas_trabajadas: cronograma.horas_trabajadas.to_f,
          tarifa_hora: cronograma.tarifa_hora.to_f,
          monto_total: cronograma.monto_total.to_f,
          estado: cronograma.estado,
          obra_nombre: cronograma.obra&.nombre,
          obra_id: cronograma.obra_id,
          created_at: cronograma.created_at&.iso8601
        }
      end

      def serialize_empresa(cronograma)
        base = serialize(cronograma)
        base.merge(
          empleado_id: cronograma.empleado_id,
          empleado_nombre: [
            cronograma.empleado&.nombre,
            cronograma.empleado&.apellido
          ].compact.join(" ")
        )
      end

      def require_empleado!
        unless current_user.rol == "empleado"
          render json: { error: "No autorizado" }, status: :forbidden
        end
      end

      def require_empresa_or_admin!
        unless ["empresa", "admin"].include?(current_user.rol)
          render json: { error: "No autorizado" }, status: :forbidden
        end
      end
    end
  end
end
