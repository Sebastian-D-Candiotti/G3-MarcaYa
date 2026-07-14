# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_07_14_170500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message_checksum", null: false
    t.string "message_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "alerta_ausencias", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "empleado_id", null: false
    t.bigint "empresa_id", null: false
    t.string "estado", limit: 20, default: "pendiente", null: false
    t.datetime "evaluado_en"
    t.date "fecha", null: false
    t.bigint "obra_id", null: false
    t.datetime "updated_at", null: false
    t.index ["empleado_id", "obra_id", "fecha"], name: "index_alerta_ausencias_on_empleado_obra_fecha", unique: true
    t.index ["empleado_id"], name: "index_alerta_ausencias_on_empleado_id"
    t.index ["empresa_id"], name: "index_alerta_ausencias_on_empresa_id"
    t.index ["obra_id"], name: "index_alerta_ausencias_on_obra_id"
  end

  create_table "asignaciones", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "empleado_id", null: false
    t.string "estado", limit: 20, default: "activo"
    t.bigint "obra_id", null: false
    t.datetime "updated_at", null: false
  end

  create_table "asistencias", force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "empleado_id", null: false
    t.date "fecha", null: false
    t.datetime "hora_entrada", precision: nil
    t.datetime "hora_salida", precision: nil
    t.decimal "horas_trabajadas", precision: 10, scale: 2
    t.float "latitud_entrada"
    t.float "latitud_salida"
    t.float "longitud_entrada"
    t.float "longitud_salida"
    t.bigint "obra_id", null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "cronograma_de_pagos", force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "empleado_id", null: false
    t.string "estado", limit: 20, default: "pendiente"
    t.decimal "horas_trabajadas", precision: 10, scale: 2, default: "0.0"
    t.decimal "monto_total", precision: 10, scale: 2, default: "0.0"
    t.bigint "obra_id", null: false
    t.string "periodo", limit: 30
    t.decimal "tarifa_hora", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "devices", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "fcm_token", null: false
    t.string "platform", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["fcm_token"], name: "index_devices_on_fcm_token", unique: true
    t.index ["user_id"], name: "index_devices_on_user_id"
  end

  create_table "empleado_obra", force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "empleado_id", null: false
    t.string "estado", limit: 20, default: "activo"
    t.datetime "fecha_ingreso", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "obra_id", null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "empleado_paradas", force: :cascade do |t|
    t.boolean "activo", default: true, null: false
    t.datetime "created_at", null: false
    t.bigint "empleado_id", null: false
    t.string "estado", limit: 20, default: "activo", null: false
    t.bigint "parada_id", null: false
    t.datetime "updated_at", null: false
    t.index ["empleado_id", "parada_id"], name: "index_empleado_paradas_on_empleado_id_and_parada_id", unique: true
  end

  create_table "empleados", force: :cascade do |t|
    t.string "apellido", limit: 100, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.text "descripcion"
    t.string "device_id"
    t.string "dni"
    t.string "estado", limit: 20, default: "activo"
    t.string "foto_url", limit: 500
    t.string "nombre", limit: 100, null: false
    t.string "telefono", limit: 20
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "usuario_id", null: false
  end

  create_table "empresas", force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.text "descripcion"
    t.string "direccion", limit: 255
    t.string "estado", limit: 20, default: "activo"
    t.string "foto_url", limit: 500
    t.string "nombre_empresa", limit: 200, null: false
    t.boolean "otp_verificado", default: false, null: false
    t.string "ruc", limit: 20, null: false
    t.string "telefono", limit: 30
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "usuario_id", null: false

    t.unique_constraint ["ruc"], name: "empresas_ruc_key"
  end

  create_table "informe_asistencias", force: :cascade do |t|
    t.string "checksum", limit: 64, null: false
    t.datetime "created_at", null: false
    t.bigint "empresa_id", null: false
    t.string "estado", limit: 20, default: "BORRADOR", null: false
    t.datetime "fecha_cierre"
    t.date "fecha_fin", null: false
    t.datetime "fecha_generacion", null: false
    t.date "fecha_inicio", null: false
    t.bigint "generado_por_id", null: false
    t.jsonb "snapshot", default: {}, null: false
    t.string "tipo_periodo", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.integer "version", default: 1, null: false
    t.index ["empresa_id", "tipo_periodo", "fecha_inicio", "fecha_fin"], name: "idx_informe_asistencias_cerrado_unico", unique: true, where: "((estado)::text = 'CERRADO'::text)"
    t.index ["empresa_id"], name: "index_informe_asistencias_on_empresa_id"
    t.index ["estado"], name: "index_informe_asistencias_on_estado"
    t.index ["fecha_fin"], name: "index_informe_asistencias_on_fecha_fin"
    t.index ["fecha_inicio"], name: "index_informe_asistencias_on_fecha_inicio"
    t.index ["generado_por_id"], name: "index_informe_asistencias_on_generado_por_id"
    t.index ["tipo_periodo"], name: "index_informe_asistencias_on_tipo_periodo"
    t.check_constraint "estado::text = ANY (ARRAY['BORRADOR'::character varying, 'CERRADO'::character varying]::text[])", name: "informe_asistencias_estado_check"
    t.check_constraint "fecha_fin >= fecha_inicio", name: "informe_asistencias_rango_fechas_check"
    t.check_constraint "tipo_periodo::text = ANY (ARRAY['DIARIO'::character varying, 'SEMANAL'::character varying, 'MENSUAL'::character varying]::text[])", name: "informe_asistencias_tipo_periodo_check"
  end

  create_table "metodo_pago", force: :cascade do |t|
    t.string "banco", limit: 100
    t.string "cci", limit: 100
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "empleado_id", null: false
    t.string "estado", limit: 20, default: "activo"
    t.string "numero_cuenta", limit: 100
    t.string "tipo", limit: 50, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "obras", force: :cascade do |t|
    t.integer "capacidad_empleados", default: 0
    t.string "codigo_obra", limit: 50
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.string "descripcion_ubicacion", limit: 255
    t.string "direccion", limit: 300
    t.bigint "empresa_id", null: false
    t.string "estado", limit: 20, default: "activa"
    t.date "fecha_fin"
    t.date "fecha_inicio"
    t.time "hora_fin", null: false
    t.time "hora_inicio", null: false
    t.float "latitud", null: false
    t.float "longitud", null: false
    t.string "nombre", limit: 150, null: false
    t.integer "radio_metros", default: 100
    t.integer "tolerancia_entrada_min", default: 5
    t.integer "tolerancia_salida_min", default: 5
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "usuario_creador_id"
  end

  create_table "paradas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "estado", limit: 20, default: "activa", null: false
    t.float "latitud", null: false
    t.float "longitud", null: false
    t.string "nombre", limit: 150, null: false
    t.bigint "obra_id", null: false
    t.integer "radio_metros", default: 50, null: false
    t.datetime "updated_at", null: false
    t.index ["obra_id", "nombre"], name: "index_paradas_on_obra_id_and_nombre", unique: true
  end

  create_table "plan_suscripciones", force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.integer "limite_empleados", null: false
    t.string "nombre", limit: 100, null: false
    t.decimal "precio", precision: 10, scale: 2, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "plan_suscripcions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "limite_empleados"
    t.string "nombre"
    t.float "precio"
    t.datetime "updated_at", null: false
  end

  create_table "registro_asistencias", force: :cascade do |t|
    t.string "cliente_marcacion_id", limit: 80
    t.datetime "created_at", null: false
    t.integer "duracion_jornada"
    t.bigint "empleado_id", null: false
    t.datetime "fecha_hora", null: false
    t.float "latitud_registrada", null: false
    t.float "longitud_registrada", null: false
    t.string "observaciones"
    t.bigint "parada_id", null: false
    t.string "tipo_marcacion", limit: 10, null: false
    t.datetime "updated_at", null: false
    t.boolean "valida_gps", default: true, null: false
    t.index ["cliente_marcacion_id"], name: "index_registro_asistencias_on_cliente_marcacion_id", unique: true, where: "(cliente_marcacion_id IS NOT NULL)"
    t.index ["empleado_id"], name: "index_registro_asistencias_on_empleado_id"
    t.index ["fecha_hora"], name: "index_registro_asistencias_on_fecha_hora"
    t.index ["parada_id"], name: "index_registro_asistencias_on_parada_id"
    t.index ["tipo_marcacion"], name: "index_registro_asistencias_on_tipo_marcacion"
  end

  create_table "solicitudes", force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "empleado_id", null: false
    t.bigint "empresa_id", null: false
    t.string "estado", limit: 20, default: "pendiente"
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "solicitudes_ingreso", force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "empleado_id", null: false
    t.string "estado", limit: 20, default: "pendiente"
    t.datetime "fecha_respuesta", precision: nil
    t.datetime "fecha_solicitud", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "obra_id", null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.bigint "channel_hash", null: false
    t.datetime "created_at", null: false
    t.binary "payload", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "solid_cache_entries", force: :cascade do |t|
    t.integer "byte_size", null: false
    t.datetime "created_at", null: false
    t.binary "key", null: false
    t.bigint "key_hash", null: false
    t.binary "value", null: false
    t.index ["byte_size"], name: "index_solid_cache_entries_on_byte_size"
    t.index ["key_hash", "byte_size"], name: "index_solid_cache_entries_on_key_hash_and_byte_size"
    t.index ["key_hash"], name: "index_solid_cache_entries_on_key_hash", unique: true
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "suscripciones", force: :cascade do |t|
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "empresa_id", null: false
    t.string "estado", limit: 20, default: "activa"
    t.date "fecha_fin", null: false
    t.date "fecha_inicio", null: false
    t.bigint "plan_id", null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "suscripcions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "empresa_id"
    t.string "estado"
    t.date "fecha_fin"
    t.date "fecha_inicio"
    t.integer "plan_suscripcion_id"
    t.datetime "updated_at", null: false
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "clave_hash", limit: 255, null: false
    t.datetime "codigo_expira", precision: nil
    t.string "codigo_recuperacion", limit: 10
    t.string "codigo_verificacion_digest", limit: 255
    t.datetime "codigo_verificacion_expira_en"
    t.string "correo", limit: 255, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.boolean "estado", default: true
    t.string "estado_verificacion", limit: 30, default: "ACTIVO", null: false
    t.string "rol", limit: 20, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "verificado_en"
    t.index ["estado_verificacion"], name: "index_usuarios_on_estado_verificacion"
    t.unique_constraint ["correo"], name: "usuarios_correo_key"
  end

  create_table "valoraciones", force: :cascade do |t|
    t.text "comentario"
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.bigint "empleado_id", null: false
    t.bigint "empresa_id", null: false
    t.integer "puntuacion"
    t.check_constraint "puntuacion >= 1 AND puntuacion <= 5", name: "valoraciones_puntuacion_check"
  end

  create_table "valoracions", force: :cascade do |t|
    t.string "comentario"
    t.datetime "created_at", null: false
    t.integer "empleado_id"
    t.date "fecha"
    t.integer "puntaje"
    t.datetime "updated_at", null: false
  end

  create_table "verificaciones_ruc", force: :cascade do |t|
    t.string "codigo", null: false
    t.datetime "created_at", null: false
    t.datetime "expira_at", null: false
    t.string "ruc", null: false
    t.datetime "updated_at", null: false
    t.index ["ruc"], name: "index_verificaciones_ruc_on_ruc", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alerta_ausencias", "empleados"
  add_foreign_key "alerta_ausencias", "empresas"
  add_foreign_key "alerta_ausencias", "obras"
  add_foreign_key "asignaciones", "empleados", name: "asignaciones_empleado_id_fkey"
  add_foreign_key "asignaciones", "obras", name: "asignaciones_obra_id_fkey"
  add_foreign_key "asistencias", "empleados", name: "asistencias_empleado_id_fkey"
  add_foreign_key "asistencias", "obras", name: "asistencias_obra_id_fkey"
  add_foreign_key "cronograma_de_pagos", "empleados", name: "cronograma_de_pagos_empleado_id_fkey"
  add_foreign_key "cronograma_de_pagos", "obras", name: "cronograma_de_pagos_obra_id_fkey"
  add_foreign_key "devices", "usuarios", column: "user_id", on_delete: :cascade
  add_foreign_key "empleado_obra", "empleados", name: "empleado_obra_empleado_id_fkey"
  add_foreign_key "empleado_obra", "obras", name: "empleado_obra_obra_id_fkey"
  add_foreign_key "empleado_paradas", "empleados", name: "empleado_paradas_empleado_id_fkey", on_delete: :cascade
  add_foreign_key "empleado_paradas", "paradas", name: "empleado_paradas_parada_id_fkey", on_delete: :cascade
  add_foreign_key "empleados", "usuarios", name: "empleados_usuario_id_fkey", on_delete: :cascade
  add_foreign_key "empresas", "usuarios", name: "empresas_usuario_id_fkey", on_delete: :cascade
  add_foreign_key "informe_asistencias", "empresas"
  add_foreign_key "informe_asistencias", "usuarios", column: "generado_por_id"
  add_foreign_key "metodo_pago", "empleados", name: "metodo_pago_empleado_id_fkey"
  add_foreign_key "obras", "empresas", name: "obras_empresa_id_fkey"
  add_foreign_key "paradas", "obras", name: "paradas_obra_id_fkey", on_delete: :cascade
  add_foreign_key "registro_asistencias", "empleados", on_delete: :restrict
  add_foreign_key "registro_asistencias", "paradas", on_delete: :restrict
  add_foreign_key "solicitudes", "empresas", name: "solicitudes_empresa_id_fkey"
  add_foreign_key "solicitudes_ingreso", "empleados", name: "solicitudes_ingreso_empleado_id_fkey"
  add_foreign_key "solicitudes_ingreso", "obras", name: "solicitudes_ingreso_obra_id_fkey"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "suscripciones", "empresas", name: "suscripciones_empresa_id_fkey"
  add_foreign_key "suscripciones", "plan_suscripciones", column: "plan_id", name: "suscripciones_plan_id_fkey"
  add_foreign_key "valoraciones", "empleados", name: "valoraciones_empleado_id_fkey"
  add_foreign_key "valoraciones", "empresas", name: "valoraciones_empresa_id_fkey"
end
