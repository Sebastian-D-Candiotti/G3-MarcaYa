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

# ─────────────────────────────────────────────
# 7. ASISTENCIA (registro de prueba)
# ─────────────────────────────────────────────
# Usamos el ORM Record porque no existe un modelo Rails estándar para registro_asistencias
unless ::Infrastructure::Orm::AsistenciaRecord.exists?(
  empleado_id: empleado.id,
  parada_id: parada.id,
  tipo_marcacion: "ENTRADA"
)
  ::Infrastructure::Orm::AsistenciaRecord.create!(
    empleado_id: empleado.id,
    parada_id: parada.id,
    tipo_marcacion: "ENTRADA",
    fecha_hora: Time.zone.now.change(hour: 8, min: 5),
    latitud_registrada: -12.119,
    longitud_registrada: -77.034,
    valida_gps: true
  )
  puts "  ✅ Asistencia ENTRADA: #{empleado.nombre} → #{parada.nombre}"
end

# ─────────────────────────────────────────────
# 8. SEGUNDO USUARIO EMPLEADO (pruebas)
# ─────────────────────────────────────────────
usuario_empleado2 = Usuario.find_or_create_by!(correo: "maria@marcaya.com") do |u|
  u.clave_hash = BCrypt::Password.create(PASS)
  u.rol = "empleado"
  u.estado = true
  puts "  ✅ Usuario empleado #2 creado: maria@marcaya.com / #{PASS}"
end

empleado2 = Empleado.find_or_create_by!(usuario_id: usuario_empleado2.id) do |e|
  e.nombre = "María"
  e.apellido = "López"
  e.dni = "87654321"
  e.telefono = "999111222"
  e.estado = "activo"
  puts "  ✅ Empleado #2 creado: #{e.nombre} #{e.apellido}"
end

# ─────────────────────────────────────────────
# 9. SEGUNDA OBRA + PARADA (pruebas)
# ─────────────────────────────────────────────
obra2 = Obra.find_or_create_by!(nombre: "Centro Comercial San Isidro", empresa_id: empresa.id) do |o|
  o.direccion = "Av. Javier Prado 789, San Isidro, Lima"
  o.descripcion_ubicacion = "Esquina con Salaverry"
  o.latitud = -12.098
  o.longitud = -77.032
  o.radio_metros = 80
  o.codigo_obra = "OBR-002"
  o.capacidad_empleados = 30
  o.hora_inicio = "07:00"
  o.hora_fin = "19:00"
  o.tolerancia_entrada_min = 10
  o.tolerancia_salida_min = 10
  o.fecha_inicio = Date.new(2026, 3, 1)
  o.fecha_fin = Date.new(2026, 11, 30)
  o.estado = "activa"
  o.usuario_creador_id = usuario_empresa.id
  puts "  ✅ Obra #2 creada: #{o.nombre}"
end

parada2 = Parada.find_or_create_by!(nombre: "Ingreso vehicular", obra_id: obra2.id) do |p|
  p.latitud = -12.098
  p.longitud = -77.032
  p.radio_metros = 40
  p.estado = "activa"
  puts "  ✅ Parada #2 creada: #{p.nombre}"
end

# ─────────────────────────────────────────────
# 10. ASIGNACIONES EMPLEADO #2
# ─────────────────────────────────────────────
Asignacion.find_or_create_by!(empleado_id: empleado2.id, obra_id: obra.id) do |a|
  a.estado = "activo"
  puts "  ✅ Asignación: #{empleado2.nombre} → #{obra.nombre}"
end

Asignacion.find_or_create_by!(empleado_id: empleado2.id, obra_id: obra2.id) do |a|
  a.estado = "activo"
  puts "  ✅ Asignación: #{empleado2.nombre} → #{obra2.nombre}"
end

# ─────────────────────────────────────────────
# 11. EMPLEADO-PARADA #2
# ─────────────────────────────────────────────
unless EmpleadoParada.exists?(empleado_id: empleado2.id, parada_id: parada.id)
  EmpleadoParada.create!(empleado_id: empleado2.id, parada_id: parada.id, estado: "activo", activo: true)
  puts "  ✅ Empleado-Parada: #{empleado2.nombre} → #{parada.nombre}"
end

unless EmpleadoParada.exists?(empleado_id: empleado2.id, parada_id: parada2.id)
  EmpleadoParada.create!(empleado_id: empleado2.id, parada_id: parada2.id, estado: "activo", activo: true)
  puts "  ✅ Empleado-Parada: #{empleado2.nombre} → #{parada2.nombre}"
end

# ─────────────────────────────────────────────
# 12. ASISTENCIA EMPLEADO #2
# ─────────────────────────────────────────────
unless ::Infrastructure::Orm::AsistenciaRecord.exists?(
  empleado_id: empleado2.id,
  parada_id: parada.id,
  tipo_marcacion: "ENTRADA"
)
  ::Infrastructure::Orm::AsistenciaRecord.create!(
    empleado_id: empleado2.id,
    parada_id: parada.id,
    tipo_marcacion: "ENTRADA",
    fecha_hora: Time.zone.now.change(hour: 7, min: 55),
    latitud_registrada: -12.119,
    longitud_registrada: -77.034,
    valida_gps: true
  )
  puts "  ✅ Asistencia ENTRADA: #{empleado2.nombre} → #{parada.nombre}"
end

# ─────────────────────────────────────────────
# 13. EMPLEADO SIN EMPRESA (para probar solicitar ingreso)
# ─────────────────────────────────────────────
usuario_sin_empresa = Usuario.find_or_create_by!(correo: "juan@marcaya.com") do |u|
  u.clave_hash = BCrypt::Password.create(PASS)
  u.rol = "empleado"
  u.estado = true
  puts "  ✅ Usuario sin empresa creado: juan@marcaya.com / #{PASS}"
end

Empleado.find_or_create_by!(usuario_id: usuario_sin_empresa.id) do |e|
  e.nombre = "Juan"
  e.apellido = "Pérez"
  e.dni = "11223344"
  e.telefono = "999333444"
  e.estado = "activo"
  puts "  ✅ Empleado sin empresa creado: #{e.nombre} #{e.apellido}"
end
# NOTA: no se crean asignaciones ni empleado-parada — este empleado no pertenece a ninguna empresa/obra

puts "🎉 ¡Seed completado!"
puts ""
puts "═" * 40
puts "  CREDENCIALES DE PRUEBA"
puts "═" * 40
puts "  Empresa:           empresa@marcaya.com / #{PASS}"
puts "  Empleado (asignado): empleado@marcaya.com / #{PASS}"
puts "  Empleado (asignado): maria@marcaya.com / #{PASS}"
puts "  Empleado (libre):    juan@marcaya.com / #{PASS}"
puts "═" * 40
