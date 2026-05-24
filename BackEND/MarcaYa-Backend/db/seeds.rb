# Seed data para MarcaYA Backend
# Usa has_secure_password (bcrypt) para crear passwords

puts "🌱 Sembrando datos de prueba..."

# ── Admin ─────────────────────────────────────────────────────
admin = Usuario.find_or_create_by!(correo: 'admin@marcaya.pe') do |u|
  u.nombre   = 'Admin MarcaYA'
  u.password = '123456'
  u.rol      = 'admin'
  u.estado   = 'activo'
end
puts "  ✓ Admin: #{admin.correo} (#{admin.nombre})"

# ── Empresa ───────────────────────────────────────────────────
empresa = Usuario.find_or_create_by!(correo: 'empresa@marcapp.pe') do |u|
  u.nombre   = 'Constructora Andina SAC'
  u.password = '123456'
  u.rol      = 'empresa'
  u.estado   = 'activo'
end
puts "  ✓ Empresa: #{empresa.correo} (#{empresa.nombre})"

# ── Empleado ──────────────────────────────────────────────────
empleado = Usuario.find_or_create_by!(correo: 'empleado@marcapp.pe') do |u|
  u.nombre   = 'Luis Ramirez Soto'
  u.password = '123456'
  u.rol      = 'empleado'
  u.estado   = 'activo'
end
puts "  ✓ Empleado: #{empleado.correo} (#{empleado.nombre})"

puts "✅ Seed completado — 3 usuarios creados."
