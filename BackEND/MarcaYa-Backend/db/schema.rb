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

ActiveRecord::Schema[8.1].define(version: 2026_05_19_050525) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "asistencias", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "empleado_id"
    t.boolean "es_valida_gps"
    t.date "fecha"
    t.datetime "hora_entrada"
    t.datetime "hora_salida"
    t.float "horas_trabajadas"
    t.integer "obra_id"
    t.datetime "updated_at", null: false
  end

  create_table "cronograma_de_pagos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "empresa_id"
    t.date "fecha_pago"
    t.float "monto_total"
    t.datetime "updated_at", null: false
  end

  create_table "empleados", force: :cascade do |t|
    t.string "codigo"
    t.datetime "created_at", null: false
    t.integer "empresa_id"
    t.string "estado"
    t.float "horas_trabajo_acumuladas"
    t.string "nombre"
    t.datetime "updated_at", null: false
  end

  create_table "empresas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "empleados_actuales"
    t.string "razon_social"
    t.string "ruc"
    t.datetime "updated_at", null: false
  end

  create_table "obras", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "descripcion_ubicacion"
    t.integer "empresa_id"
    t.string "estado"
    t.float "latitud"
    t.float "longitud"
    t.string "nombre"
    t.float "radio_metros"
    t.datetime "updated_at", null: false
  end

  create_table "plan_suscripcions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "limite_empleados"
    t.string "nombre"
    t.float "precio"
    t.datetime "updated_at", null: false
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
    t.string "clave_hash"
    t.string "correo"
    t.datetime "created_at", null: false
    t.string "nombre"
    t.string "rol"
    t.datetime "updated_at", null: false
  end

  create_table "valoracions", force: :cascade do |t|
    t.string "comentario"
    t.datetime "created_at", null: false
    t.integer "empleado_id"
    t.date "fecha"
    t.integer "puntaje"
    t.datetime "updated_at", null: false
  end
end
