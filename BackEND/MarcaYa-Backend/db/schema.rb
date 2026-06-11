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

ActiveRecord::Schema[8.1].define(version: 2026_06_09_000100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

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
    t.string "periodo", limit: 20
    t.decimal "tarifa_hora", precision: 10, scale: 2, default: "0.0"
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
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
    t.string "correo", limit: 255, null: false
    t.datetime "created_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }
    t.boolean "estado", default: true
    t.string "estado_verificacion", limit: 30, default: "ACTIVO", null: false
    t.string "codigo_verificacion_digest", limit: 255
    t.datetime "codigo_verificacion_expira_en"
    t.datetime "verificado_en"
    t.string "rol", limit: 20, null: false
    t.datetime "updated_at", precision: nil, default: -> { "CURRENT_TIMESTAMP" }

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

  add_foreign_key "asignaciones", "empleados", name: "asignaciones_empleado_id_fkey"
  add_foreign_key "asignaciones", "obras", name: "asignaciones_obra_id_fkey"
  add_foreign_key "asistencias", "empleados", name: "asistencias_empleado_id_fkey"
  add_foreign_key "asistencias", "obras", name: "asistencias_obra_id_fkey"
  add_foreign_key "cronograma_de_pagos", "empleados", name: "cronograma_de_pagos_empleado_id_fkey"
  add_foreign_key "cronograma_de_pagos", "obras", name: "cronograma_de_pagos_obra_id_fkey"
  add_foreign_key "empleado_obra", "empleados", name: "empleado_obra_empleado_id_fkey"
  add_foreign_key "empleado_obra", "obras", name: "empleado_obra_obra_id_fkey"
  add_foreign_key "empleado_paradas", "empleados", name: "empleado_paradas_empleado_id_fkey", on_delete: :cascade
  add_foreign_key "empleado_paradas", "paradas", name: "empleado_paradas_parada_id_fkey", on_delete: :cascade
  add_foreign_key "metodo_pago", "empleados", name: "metodo_pago_empleado_id_fkey"
  add_foreign_key "obras", "empresas", name: "obras_empresa_id_fkey"
  add_foreign_key "paradas", "obras", name: "paradas_obra_id_fkey", on_delete: :cascade
  add_foreign_key "registro_asistencias", "empleados", on_delete: :restrict
  add_foreign_key "registro_asistencias", "paradas", on_delete: :restrict
  add_foreign_key "solicitudes", "empresas", name: "solicitudes_empresa_id_fkey"
  add_foreign_key "solicitudes_ingreso", "empleados", name: "solicitudes_ingreso_empleado_id_fkey"
  add_foreign_key "solicitudes_ingreso", "obras", name: "solicitudes_ingreso_obra_id_fkey"
  add_foreign_key "suscripciones", "empresas", name: "suscripciones_empresa_id_fkey"
  add_foreign_key "suscripciones", "plan_suscripciones", column: "plan_id", name: "suscripciones_plan_id_fkey"
  add_foreign_key "valoraciones", "empleados", name: "valoraciones_empleado_id_fkey"
  add_foreign_key "valoraciones", "empresas", name: "valoraciones_empresa_id_fkey"
end
