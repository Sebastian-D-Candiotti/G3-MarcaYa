class EstadisticasSerializer
  include JSONAPI::Serializer

  attributes :tipo, :periodo, :horas_promedio, :horas_totales, :puntualidad_porcentaje,
             :dias_trabajados, :tardanzas_total, :faltas_total, :fake_gps_intentos

  # Atributos condicionales según el tipo
  attribute :empleado_id, if: proc { |record| record[:tipo] == 'empleado' }
  attribute :empleado_nombre, if: proc { |record| record[:tipo] == 'empleado' }

  attribute :obra_id, if: proc { |record| record[:tipo] == 'obra' }
  attribute :obra_nombre, if: proc { |record| record[:tipo] == 'obra' }
  attribute :empresa_id, if: proc { |record| record[:tipo] == 'obra' }
  attribute :empleados_activos, if: proc { |record| record[:tipo] == 'obra' }
  attribute :empleados_con_irregularidades, if: proc { |record| record[:tipo] == 'obra' }
  attribute :datos_por_empleado, if: proc { |record| record[:tipo] == 'obra' }

  attribute :empresa_id, if: proc { |record| record[:tipo] == 'empresa' }
  attribute :empresa_nombre, if: proc { |record| record[:tipo] == 'empresa' }
  attribute :obras_activas, if: proc { |record| record[:tipo] == 'empresa' }
  attribute :empleados_activos, if: proc { |record| record[:tipo] == 'empresa' }

  attribute :datos_diarios, if: proc { |record| record[:tipo] == 'empleado' }
end
