# frozen_string_literal: true

# =============================================
# MarcaYa — Seeds
# =============================================
# Crea usuarios de prueba para desarrollo.
# Ejecutar con: bin/rails db:seed
# Es seguro ejecutarlo múltiples veces (idempotente).
# =============================================

require "bcrypt"

PASS = "123456"

puts "🌱 Sembrando datos de prueba..."

# ─────────────────────────────────────────────
# 1. USUARIO EMPRESA
# ─────────────────────────────────────────────
usuario_empresa = Usuario.find_or_create_by!(correo: "empresa@marcaya.com") do |u|
  u.clave_hash = BCrypt::Password.create(PASS)
  u.rol = "empresa"
  u.estado = true
  puts "  ✅ Usuario empresa creado: empresa@marcaya.com / #{PASS}"
end

empresa = Empresa.find_or_create_by!(usuario_id: usuario_empresa.id) do |e|
  e.nombre_empresa = "Constructora Lima S.A.C."
  e.ruc = "20123456789"
  e.direccion = "Av. Principal 123, Lima"
  e.telefono = "999888777"
  e.estado = "activo"
  puts "  ✅ Empresa creada: #{e.nombre_empresa}"
end

# ─────────────────────────────────────────────
# 2. USUARIO EMPLEADO
# ─────────────────────────────────────────────
usuario_empleado = Usuario.find_or_create_by!(correo: "empleado@marcaya.com") do |u|
  u.clave_hash = BCrypt::Password.create(PASS)
  u.rol = "empleado"
  u.estado = true
  puts "  ✅ Usuario empleado creado: empleado@marcaya.com / #{PASS}"
end

empleado = Empleado.find_or_create_by!(usuario_id: usuario_empleado.id) do |e|
  e.nombre = "Carlos"
  e.apellido = "García"
  e.dni = "12345678"
  e.telefono = "987654321"
  e.estado = "activo"
  puts "  ✅ Empleado creado: #{e.nombre} #{e.apellido}"
end

# ─────────────────────────────────────────────
# 3. OBRA
# ─────────────────────────────────────────────
# Coordenadas aproximadas de Miraflores, Lima (-12.119, -77.034)
obra = Obra.find_or_create_by!(nombre: "Edificio Corporativo Miraflores", empresa_id: empresa.id) do |o|
  o.direccion = "Av. Larco 456, Miraflores, Lima"
  o.descripcion_ubicacion = "Cerca del parque Kennedy"
  o.latitud = -12.119
  o.longitud = -77.034
  o.radio_metros = 100
  o.codigo_obra = "OBR-001"
  o.capacidad_empleados = 20
  o.hora_inicio = "08:00"
  o.hora_fin = "18:00"
  o.tolerancia_entrada_min = 15
  o.tolerancia_salida_min = 15
  o.fecha_inicio = Date.new(2026, 1, 15)
  o.fecha_fin = Date.new(2026, 12, 20)
  o.estado = "activa"
  o.usuario_creador_id = usuario_empresa.id
  puts "  ✅ Obra creada: #{o.nombre}"
end

# ─────────────────────────────────────────────
# 4. PARADA (punto de marcación dentro de la obra)
# ─────────────────────────────────────────────
parada = Parada.find_or_create_by!(nombre: "Puerta principal", obra_id: obra.id) do |p|
  p.latitud = -12.119
  p.longitud = -77.034
  p.radio_metros = 50
  p.estado = "activa"
  puts "  ✅ Parada creada: #{p.nombre}"
end

# ─────────────────────────────────────────────
# 5. ASIGNACIÓN (empleado → obra)
# ─────────────────────────────────────────────
Asignacion.find_or_create_by!(empleado_id: empleado.id, obra_id: obra.id) do |a|
  a.estado = "activo"
  puts "  ✅ Asignación: #{empleado.nombre} → #{obra.nombre}"
end

# ─────────────────────────────────────────────
# 6. EMPLEADO-PARADA (empleado puede marcar en esta parada)
# ─────────────────────────────────────────────
unless EmpleadoParada.exists?(empleado_id: empleado.id, parada_id: parada.id)
  EmpleadoParada.create!(empleado_id: empleado.id, parada_id: parada.id, estado: "activo", activo: true)
  puts "  ✅ Empleado-Parada: #{empleado.nombre} → #{parada.nombre}"
end

puts "🎉 ¡Seed completado!"
puts ""
puts "═" * 40
puts "  CREDENCIALES DE PRUEBA"
puts "═" * 40
puts "  Empresa:   empresa@marcaya.com / #{PASS}"
puts "  Empleado:  empleado@marcaya.com / #{PASS}"
puts "═" * 40
