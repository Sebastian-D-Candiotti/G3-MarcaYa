-- ============================================================
-- MarcaYA — Datos de demostración para Supabase
-- Empresa ID: 6 (MarcaYA)
-- Empleado ID: 7
-- Generado: 2026-07-13
-- ============================================================

-- ════════════════════════════════════════════════════════════════
-- 1. USUARIOS (empresa + empleados)
-- ════════════════════════════════════════════════════════════════

-- Usuario de la empresa MarcaYA (id=6)
INSERT INTO usuarios (id, correo, clave_hash, rol, estado, estado_verificacion, verificado_en, created_at, updated_at)
VALUES (
  6,
  'admin@marcaya.com.pe',
  '$2a$12$LJ3m4ys3Gz3tAoVbM8GhWOJh8xQZkKzCmGQYV5Xf5Xf5Xf5Xf5Xf', -- hash bcrypt demo
  'empresa',
  true,
  'ACTIVO',
  '2026-06-01 10:00:00',
  '2026-06-01 10:00:00',
  '2026-07-13 12:00:00'
)
ON CONFLICT (correo) DO NOTHING;

-- Empleado principal (id=7) — Juan Carlos Méndez
INSERT INTO usuarios (id, correo, clave_hash, rol, estado, estado_verificacion, verificado_en, created_at, updated_at)
VALUES (
  7,
  'juan.mendez@marcaya.com.pe',
  '$2a$12$LJ3m4ys3Gz3tAoVbM8GhWOJh8xQZkKzCmGQYV5Xf5Xf5Xf5Xf5',
  'empleado',
  true,
  'ACTIVO',
  '2026-06-05 09:00:00',
  '2026-06-05 09:00:00',
  '2026-07-13 12:00:00'
)
ON CONFLICT (correo) DO NOTHING;

-- Empleados adicionales
INSERT INTO usuarios (correo, clave_hash, rol, estado, estado_verificacion, verificado_en, created_at, updated_at)
VALUES
  ('maria.garcia@marcaya.com.pe', '$2a$12$LJ3m4ys3Gz3tAoVbM8GhWOJh8xQZkKzCmGQYV5Xf5Xf5Xf5Xf5', 'empleado', true, 'ACTIVO', '2026-06-05 09:00:00', '2026-06-05 09:00:00', NOW()),
  ('carlos.rodriguez@marcaya.com.pe', '$2a$12$LJ3m4ys3Gz3tAoVbM8GhWOJh8xQZkKzCmGQYV5Xf5Xf5Xf5Xf5', 'empleado', true, 'ACTIVO', '2026-06-10 08:30:00', '2026-06-10 08:30:00', NOW()),
  ('ana.martinez@marcaya.com.pe', '$2a$12$LJ3m4ys3Gz3tAoVbM8GhWOJh8xQZkKzCmGQYV5Xf5Xf5Xf5Xf5', 'empleado', true, 'ACTIVO', '2026-06-12 09:15:00', '2026-06-12 09:15:00', NOW()),
  ('pedro.sanchez@marcaya.com.pe', '$2a$12$LJ3m4ys3Gz3tAoVbM8GhWOJh8xQZkKzCmGQYV5Xf5Xf5Xf5Xf5', 'empleado', true, 'ACTIVO', '2026-06-15 10:00:00', '2026-06-15 10:00:00', NOW()),
  ('lucia.fernandez@marcaya.com.pe', '$2a$12$LJ3m4ys3Gz3tAoVbM8GhWOJh8xQZkKzCmGQYV5Xf5Xf5Xf5Xf5', 'empleado', true, 'ACTIVO', '2026-06-18 08:45:00', '2026-06-18 08:45:00', NOW()),
  ('roberto.diaz@marcaya.com.pe', '$2a$12$LJ3m4ys3Gz3tAoVbM8GhWOJh8xQZkKzCmGQYV5Xf5Xf5Xf5Xf5', 'empleado', true, 'ACTIVO', '2026-06-20 09:30:00', '2026-06-20 09:30:00', NOW())
ON CONFLICT (correo) DO NOTHING;

-- ════════════════════════════════════════════════════════════════
-- 2. EMPRESA MarcaYA (id=6)
-- ════════════════════════════════════════════════════════════════

INSERT INTO empresas (id, usuario_id, nombre_empresa, ruc, descripcion, telefono, direccion, foto_url, estado, otp_verificado, created_at, updated_at)
VALUES (
  6,
  6,
  'MarcaYA Constructora S.A.C.',
  '20601234567',
  'Empresa constructora especializada en infraestructura urbana y edificaciones residenciales. Más de 15 años de experiencia en el mercado peruano.',
  '01 456 7890',
  'Av. Javier Prado Este 4600, Santiago de Surco, Lima',
  'https://ui-avatars.com/api/?name=MarcaYA&background=38A3A5&color=fff&size=200&bold=true',
  'activo',
  true,
  '2026-06-01 10:00:00',
  '2026-07-13 12:00:00'
)
ON CONFLICT (id) DO UPDATE SET
  nombre_empresa = EXCLUDED.nombre_empresa,
  descripcion = EXCLUDED.descripcion,
  telefono = EXCLUDED.telefono,
  direccion = EXCLUDED.direccion,
  foto_url = EXCLUDED.foto_url,
  updated_at = NOW();

-- ════════════════════════════════════════════════════════════════
-- 3. EMPLEADOS
-- ════════════════════════════════════════════════════════════════

-- Empleado 7: Juan Carlos Méndez (principal)
INSERT INTO empleados (id, usuario_id, nombre, apellido, dni, telefono, descripcion, foto_url, estado, device_id, created_at, updated_at)
VALUES (
  7,
  7,
  'Juan Carlos',
  'Méndez López',
  '70123456',
  '951234567',
  'Maestro de obras — 8 años de experiencia en construcción civil',
  'https://ui-avatars.com/api/?name=Juan+Carlos&background=38A3A5&color=fff&size=200',
  'activo',
  'android-emulator-001',
  '2026-06-05 09:00:00',
  '2026-07-13 12:00:00'
)
ON CONFLICT (id) DO UPDATE SET
  descripcion = EXCLUDED.descripcion,
  foto_url = EXCLUDED.foto_url,
  updated_at = NOW();

-- Empleados adicionales
INSERT INTO empleados (usuario_id, nombre, apellido, dni, telefono, descripcion, foto_url, estado, created_at, updated_at)
VALUES
  -- María García (id will auto-increment)
  ((SELECT id FROM usuarios WHERE correo = 'maria.garcia@marcaya.com.pe'), 'María Alejandra', 'García Torres', '70234567', '952345678', 'Ingeniera de seguridad — certificada en NEBOSH', 'https://ui-avatars.com/api/?name=María+García&background=10B981&color=fff&size=200', 'activo', '2026-06-05 09:00:00', NOW()),
  -- Carlos Rodríguez
  ((SELECT id FROM usuarios WHERE correo = 'carlos.rodriguez@marcaya.com.pe'), 'Carlos Alberto', 'Rodríguez Vega', '70345678', '953456789', 'Albañil certificado — especialista en estructuras', 'https://ui-avatars.com/api/?name=Carlos+Rodríguez&background=F59E0B&color=fff&size=200', 'activo', '2026-06-10 08:30:00', NOW()),
  -- Ana Martínez
  ((SELECT id FROM usuarios WHERE correo = 'ana.martinez@marcaya.com.pe'), 'Ana Lucía', 'Martínez Ríos', '70456789', '954567890', 'Topógrafa — experiencia en levantamientos topográficos', 'https://ui-avatars.com/api/?name=Ana+Martínez&background=EF4444&color=fff&size=200', 'activo', '2026-06-12 09:15:00', NOW()),
  -- Pedro Sánchez
  ((SELECT id FROM usuarios WHERE correo = 'pedro.sanchez@marcaya.com.pe'), 'Pedro Luis', 'Sánchez Moreno', '70567890', '955678901', 'Operador de maquinaria pesada — 5 años de experiencia', 'https://ui-avatars.com/api/?name=Pedro+Sánchez&background=7C3AED&color=fff&size=200', 'activo', '2026-06-15 10:00:00', NOW()),
  -- Lucía Fernández
  ((SELECT id FROM usuarios WHERE correo = 'lucia.fernandez@marcaya.com.pe'), 'Lucía Fernanda', 'Fernández Cruz', '70678901', '956789012', 'Auxiliar de administración — control de asistencia', 'https://ui-avatars.com/api/?name=Lucía+Fernández&background=06B6D4&color=fff&size=200', 'activo', '2026-06-18 08:45:00', NOW()),
  -- Roberto Díaz
  ((SELECT id FROM usuarios WHERE correo = 'roberto.diaz@marcaya.com.pe'), 'Roberto Carlos', 'Díaz Paredes', '70789012', '957890123', 'Electricista certificado — instalaciones industriales', 'https://ui-avatars.com/api/?name=Roberto+Díaz&background=EA580C&color=fff&size=200', 'activo', '2026-06-20 09:30:00', NOW());

-- ════════════════════════════════════════════════════════════════
-- 4. OBRAS
-- ════════════════════════════════════════════════════════════════

INSERT INTO obras (empresa_id, nombre, descripcion_ubicacion, latitud, longitud, radio_metros, hora_inicio, hora_fin, tolerancia_entrada_min, tolerancia_salida_min, estado, fecha_inicio, fecha_fin, direccion, capacidad_empleados, codigo_obra, usuario_creador_id, created_at, updated_at)
VALUES
  -- Obra 1: Torres del Parque
  (6, 'Torres del Parque', 'Urbanización Residencial en Surco', -12.1354, -76.9947, 100, '07:00:00', '17:00:00', 10, 10, 'activa', '2026-06-01', '2026-12-31', 'Av. Benavides 4500, Surco', 80, 'OB-MY-001', 6, '2026-06-01 10:00:00', NOW()),
  -- Obra 2: Centro Comercial Real Plaza
  (6, 'Centro Comercial Real Plaza', 'Mall en Ate', -12.0464, -76.9428, 80, '06:00:00', '18:00:00', 15, 5, 'activa', '2026-05-15', '2026-11-30', 'Av. San Pablo 3500, Ate', 120, 'OB-MY-002', 6, '2026-05-15 08:00:00', NOW()),
  -- Obra 3: Puente Villa El Salvador
  (6, 'Puente Villa El Salvador', 'Infraestructura vial', -12.2104, -76.9328, 150, '05:30:00', '15:30:00', 5, 5, 'activa', '2026-06-10', '2026-09-30', 'Vía Expresa Villa El Salvador', 50, 'OB-MY-003', 6, '2026-06-10 07:00:00', NOW());

-- ════════════════════════════════════════════════════════════════
-- 5. PARADAS (puntos de marcación)
-- ════════════════════════════════════════════════════════════════

INSERT INTO paradas (obra_id, nombre, latitud, longitud, radio_metros, estado, created_at, updated_at)
VALUES
  -- Torres del Parque
  ((SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), 'Entrada Principal Torres', -12.1354, -76.9947, 50, 'activa', NOW(), NOW()),
  ((SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), 'Zona de Estacionamiento', -12.1358, -76.9950, 40, 'activa', NOW(), NOW()),
  ((SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), 'Planta de Mezcla', -12.1350, -76.9944, 30, 'activa', NOW(), NOW()),

  -- Centro Comercial Real Plaza
  ((SELECT id FROM obras WHERE codigo_obra = 'OB-MY-002'), 'Puerta Norte', -12.0464, -76.9428, 60, 'activa', NOW(), NOW()),
  ((SELECT id FROM obras WHERE codigo_obra = 'OB-MY-002'), 'Zona de Carga', -12.0468, -76.9430, 45, 'activa', NOW(), NOW()),

  -- Puente Villa El Salvador
  ((SELECT id FROM obras WHERE codigo_obra = 'OB-MY-003'), 'Control de Acceso Sur', -12.2104, -76.9328, 70, 'activa', NOW(), NOW()),
  ((SELECT id FROM obras WHERE codigo_obra = 'OB-MY-003'), 'Centro del Puente', -12.2100, -76.9325, 80, 'activa', NOW(), NOW());

-- ════════════════════════════════════════════════════════════════
-- 6. ASIGNACIONES (empleados → obras)
-- ════════════════════════════════════════════════════════════════

INSERT INTO asignaciones (empleado_id, obra_id, estado, created_at, updated_at)
VALUES
  -- Empleado 7: asignado a Torres del Parque (principal) y Centro Comercial
  (7, (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), 'activo', '2026-06-05 09:00:00', NOW()),
  (7, (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-002'), 'activo', '2026-06-15 10:00:00', NOW()),
  -- María: Torres del Parque
  ((SELECT id FROM empleados WHERE dni = '70234567'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), 'activo', '2026-06-05 09:00:00', NOW()),
  -- Carlos: Centro Comercial
  ((SELECT id FROM empleados WHERE dni = '70345678'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-002'), 'activo', '2026-06-10 08:30:00', NOW()),
  -- Ana: Torres + Puente
  ((SELECT id FROM empleados WHERE dni = '70456789'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), 'activo', '2026-06-12 09:15:00', NOW()),
  ((SELECT id FROM empleados WHERE dni = '70456789'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-003'), 'activo', '2026-06-20 08:00:00', NOW()),
  -- Pedro: Puente
  ((SELECT id FROM empleados WHERE dni = '70567890'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-003'), 'activo', '2026-06-15 10:00:00', NOW()),
  -- Lucía: Centro Comercial
  ((SELECT id FROM empleados WHERE dni = '70678901'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-002'), 'activo', '2026-06-18 08:45:00', NOW()),
  -- Roberto: Torres
  ((SELECT id FROM empleados WHERE dni = '70789012'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), 'activo', '2026-06-20 09:30:00', NOW());

-- ════════════════════════════════════════════════════════════════
-- 7. EMPLEADO_PARADAS (asignación a puntos de marcación)
-- ════════════════════════════════════════════════════════════════

INSERT INTO empleado_paradas (empleado_id, parada_id, activo, estado, created_at, updated_at)
VALUES
  -- Empleado 7 → Torres del Parque: Entrada Principal
  (7, (SELECT id FROM paradas WHERE nombre = 'Entrada Principal Torres'), true, 'activo', NOW(), NOW()),
  -- Empleado 7 → Centro Comercial: Puerta Norte
  (7, (SELECT id FROM paradas WHERE nombre = 'Puerta Norte'), true, 'activo', NOW(), NOW()),
  -- María → Torres: Entrada Principal
  ((SELECT id FROM empleados WHERE dni = '70234567'), (SELECT id FROM paradas WHERE nombre = 'Entrada Principal Torres'), true, 'activo', NOW(), NOW()),
  -- Carlos → Centro Comercial: Puerta Norte
  ((SELECT id FROM empleados WHERE dni = '70345678'), (SELECT id FROM paradas WHERE nombre = 'Puerta Norte'), true, 'activo', NOW(), NOW()),
  -- Ana → Torres: Zona Estacionamiento
  ((SELECT id FROM empleados WHERE dni = '70456789'), (SELECT id FROM paradas WHERE nombre = 'Zona de Estacionamiento'), true, 'activo', NOW(), NOW()),
  -- Pedro → Puente: Control de Acceso
  ((SELECT id FROM empleados WHERE dni = '70567890'), (SELECT id FROM paradas WHERE nombre = 'Control de Acceso Sur'), true, 'activo', NOW(), NOW()),
  -- Lucía → Centro Comercial: Zona de Carga
  ((SELECT id FROM empleados WHERE dni = '70678901'), (SELECT id FROM paradas WHERE nombre = 'Zona de Carga'), true, 'activo', NOW(), NOW()),
  -- Roberto → Torres: Planta de Mezcla
  ((SELECT id FROM empleados WHERE dni = '70789012'), (SELECT id FROM paradas WHERE nombre = 'Planta de Mezcla'), true, 'activo', NOW(), NOW());

-- ════════════════════════════════════════════════════════════════
-- 8. REGISTRO DE ASISTENCIAS — Empleado 7 (Juan Carlos)
--    2 semanas de datos realistas: lun-vie, entrada ~07:00, salida ~17:00
-- ════════════════════════════════════════════════════════════════

-- Primero obtener IDs necesarios
DO $$
DECLARE
  parada_torres_id BIGINT;
  parada_cc_id BIGINT;
  empleado_7_id BIGINT := 7;
  fecha_base DATE;
  i INT;
  hora_ent TIME;
  hora_sal TIME;
  lat_base DOUBLE PRECISION;
  lng_base DOUBLE PRECISION;
  duracion INT;
BEGIN
  SELECT id INTO parada_torres_id FROM paradas WHERE nombre = 'Entrada Principal Torres';
  SELECT id INTO parada_cc_id FROM paradas WHERE nombre = 'Puerta Norte';

  -- Semana 1: 30 jun - 4 jul 2026 (Torres del Parque)
  fecha_base := '2026-06-30';
  FOR i IN 0..4 LOOP
    -- Entrada: 06:50 - 06:59 (variación realista)
    hora_ent := ('06:' || LPAD((50 + (random() * 9)::int)::text, 2, '0'))::time;
    -- Salida: 16:50 - 16:59
    hora_sal := ('16:' || LPAD((50 + (random() * 9)::int)::text, 2, '0'))::time;
    duracion := EXTRACT(EPOCH FROM (hora_sal - hora_ent)) / 3600;
    lat_base := -12.1354 + (random() * 0.0004 - 0.0002);
    lng_base := -76.9947 + (random() * 0.0004 - 0.0002);

    -- Entrada
    INSERT INTO registro_asistencias (empleado_id, parada_id, fecha_hora, tipo_marcacion, latitud_registrada, longitud_registrada, valida_gps, duracion_jornada, cliente_marcacion_id, observaciones, created_at, updated_at)
    VALUES (
      empleado_7_id, parada_torres_id,
      (fecha_base + i * INTERVAL '1 day' + hora_ent),
      'entrada', lat_base, lng_base, true, NULL,
      'cli-' || empleado_7_id || '-' || (fecha_base + i * INTERVAL '1 day') || '-ent',
      NULL, NOW(), NOW()
    );

    -- Salida
    INSERT INTO registro_asistencias (empleado_id, parada_id, fecha_hora, tipo_marcacion, latitud_registrada, longitud_registrada, valida_gps, duracion_jornada, cliente_marcacion_id, observaciones, created_at, updated_at)
    VALUES (
      empleado_7_id, parada_torres_id,
      (fecha_base + i * INTERVAL '1 day' + hora_sal),
      'salida', lat_base, lng_base, true, duracion,
      'cli-' || empleado_7_id || '-' || (fecha_base + i * INTERVAL '1 day') || '-sal',
      NULL, NOW(), NOW()
    );

    -- also insert into asistencias table
    INSERT INTO asistencias (empleado_id, obra_id, fecha, hora_entrada, hora_salida, horas_trabajadas, latitud_entrada, longitud_entrada, latitud_salida, longitud_salida, created_at, updated_at)
    VALUES (
      empleado_7_id,
      (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'),
      fecha_base + i * INTERVAL '1 day',
      (fecha_base + i * INTERVAL '1 day' + hora_ent),
      (fecha_base + i * INTERVAL '1 day' + hora_sal),
      ROUND((EXTRACT(EPOCH FROM (hora_sal - hora_ent)) / 3600)::numeric, 2),
      lat_base, lng_base, lat_base + 0.0001, lng_base + 0.0001,
      NOW(), NOW()
    );
  END LOOP;

  -- Semana 2: 7 jul - 11 jul 2026 (Torres del Parque)
  fecha_base := '2026-07-07';
  FOR i IN 0..4 LOOP
    hora_ent := ('06:' || LPAD((50 + (random() * 9)::int)::text, 2, '0'))::time;
    hora_sal := ('16:' || LPAD((50 + (random() * 9)::int)::text, 2, '0'))::time;
    duracion := EXTRACT(EPOCH FROM (hora_sal - hora_ent)) / 3600;
    lat_base := -12.1354 + (random() * 0.0004 - 0.0002);
    lng_base := -76.9947 + (random() * 0.0004 - 0.0002);

    INSERT INTO registro_asistencias (empleado_id, parada_id, fecha_hora, tipo_marcacion, latitud_registrada, longitud_registrada, valida_gps, duracion_jornada, cliente_marcacion_id, observaciones, created_at, updated_at)
    VALUES (
      empleado_7_id, parada_torres_id,
      (fecha_base + i * INTERVAL '1 day' + hora_ent),
      'entrada', lat_base, lng_base, true, NULL,
      'cli-' || empleado_7_id || '-' || (fecha_base + i * INTERVAL '1 day') || '-ent',
      NULL, NOW(), NOW()
    );

    INSERT INTO registro_asistencias (empleado_id, parada_id, fecha_hora, tipo_marcacion, latitud_registrada, longitud_registrada, valida_gps, duracion_jornada, cliente_marcacion_id, observaciones, created_at, updated_at)
    VALUES (
      empleado_7_id, parada_torres_id,
      (fecha_base + i * INTERVAL '1 day' + hora_sal),
      'salida', lat_base, lng_base, true, duracion,
      'cli-' || empleado_7_id || '-' || (fecha_base + i * INTERVAL '1 day') || '-sal',
      NULL, NOW(), NOW()
    );

    INSERT INTO asistencias (empleado_id, obra_id, fecha, hora_entrada, hora_salida, horas_trabajadas, latitud_entrada, longitud_entrada, latitud_salida, longitud_salida, created_at, updated_at)
    VALUES (
      empleado_7_id,
      (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'),
      fecha_base + i * INTERVAL '1 day',
      (fecha_base + i * INTERVAL '1 day' + hora_ent),
      (fecha_base + i * INTERVAL '1 day' + hora_sal),
      ROUND((EXTRACT(EPOCH FROM (hora_sal - hora_ent)) / 3600)::numeric, 2),
      lat_base, lng_base, lat_base + 0.0001, lng_base + 0.0001,
      NOW(), NOW()
    );
  END LOOP;

  -- Semana 2 viernes 11 jul → Centro Comercial (turno especial)
  hora_ent := '05:50:00'::time;
  hora_sal := '15:55:00'::time;
  duracion := EXTRACT(EPOCH FROM (hora_sal - hora_ent)) / 3600;
  lat_base := -12.0464 + (random() * 0.0004 - 0.0002);
  lng_base := -76.9428 + (random() * 0.0004 - 0.0002);

  INSERT INTO registro_asistencias (empleado_id, parada_id, fecha_hora, tipo_marcacion, latitud_registrada, longitud_registrada, valida_gps, duracion_jornada, cliente_marcacion_id, observaciones, created_at, updated_at)
  VALUES
    (empleado_7_id, parada_cc_id, '2026-07-11 05:50:00', 'entrada', lat_base, lng_base, true, NULL, 'cli-7-2026-07-11-ent', 'Turno especial en Centro Comercial', NOW(), NOW()),
    (empleado_7_id, parada_cc_id, '2026-07-11 15:55:00', 'salida', lat_base, lng_base, true, duracion, 'cli-7-2026-07-11-sal', NULL, NOW(), NOW());

  INSERT INTO asistencias (empleado_id, obra_id, fecha, hora_entrada, hora_salida, horas_trabajadas, latitud_entrada, longitud_entrada, latitud_salida, longitud_salida, created_at, updated_at)
  VALUES (
    empleado_7_id,
    (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-002'),
    '2026-07-11', '2026-07-11 05:50:00', '2026-07-11 15:55:00', 10.08,
    lat_base, lng_base, lat_base + 0.0001, lng_base + 0.0001,
    NOW(), NOW()
  );

  -- HOY (13 jul 2026) — lunes: entrada registrada, sin salida aún
  hora_ent := '06:55:00'::time;
  lat_base := -12.1354;
  lng_base := -76.9947;

  INSERT INTO registro_asistencias (empleado_id, parada_id, fecha_hora, tipo_marcacion, latitud_registrada, longitud_registrada, valida_gps, duracion_jornada, cliente_marcacion_id, observaciones, created_at, updated_at)
  VALUES (
    empleado_7_id, parada_torres_id,
    '2026-07-13 06:55:00', 'entrada',
    lat_base, lng_base, true, NULL,
    'cli-7-2026-07-13-ent',
    NULL, NOW(), NOW()
  );

END $$;

-- ════════════════════════════════════════════════════════════════
-- 9. ASISTENCIAS HOY (resumen para el dashboard)
-- ════════════════════════════════════════════════════════════════

-- Ya insertadas en el bloque anterior via asistencias table

-- ════════════════════════════════════════════════════════════════
-- 10. VALORACIONES (comentarios de empleados a la empresa)
-- ════════════════════════════════════════════════════════════════

INSERT INTO valoraciones (empleado_id, empresa_id, puntuacion, comentario, created_at)
VALUES
  (7, 6, 5, 'Excelente empresa, siempre pagan a tiempo y el ambiente laboral es genial.', '2026-06-20 14:00:00'),
  ((SELECT id FROM empleados WHERE dni = '70234567'), 6, 4, 'Muy buena organización en las obras. Recomendada.', '2026-06-22 10:30:00'),
  ((SELECT id FROM empleados WHERE dni = '70345678'), 6, 5, 'La mejor constructora en la que he trabajado. Seguridad primero.', '2026-06-25 16:00:00'),
  ((SELECT id FROM empleados WHERE dni = '70456789'), 6, 4, 'Buenas prestaciones y trato digno a los trabajadores.', '2026-06-28 09:00:00'),
  ((SELECT id FROM empleados WHERE dni = '70567890'), 6, 5, 'Equipos de última generación y capacitación constante.', '2026-07-01 11:00:00');

-- ════════════════════════════════════════════════════════════════
-- 11. ALERTAS DE AUSENCIA (una pendiente para demo)
-- ════════════════════════════════════════════════════════════════

INSERT INTO alerta_ausencias (empleado_id, empresa_id, obra_id, fecha, estado, created_at, updated_at)
VALUES (
  (SELECT id FROM empleados WHERE dni = '70678901'), -- Lucía
  6,
  (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-002'),
  CURRENT_DATE - INTERVAL '1 day',
  'pendiente',
  NOW(),
  NOW()
)
ON CONFLICT (empleado_id, obra_id, fecha) DO NOTHING;

-- ════════════════════════════════════════════════════════════════
-- 12. SOLICITUDES DE INGRESO
-- ════════════════════════════════════════════════════════════════

INSERT INTO solicitudes_ingreso (empleado_id, obra_id, estado, fecha_solicitud, created_at, updated_at)
VALUES
  ((SELECT id FROM empleados WHERE dni = '70789012'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), 'aprobada', '2026-06-19 14:00:00', '2026-06-19 14:00:00', NOW()),
  ((SELECT id FROM empleados WHERE dni = '70678901'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-002'), 'aprobada', '2026-06-17 10:00:00', '2026-06-17 10:00:00', NOW());

-- ════════════════════════════════════════════════════════════════
-- 13. CRONOGRAMA DE PAGOS (demo)
-- ════════════════════════════════════════════════════════════════

INSERT INTO cronograma_de_pagos (empleado_id, obra_id, periodo, horas_trabajadas, tarifa_hora, monto_total, estado, created_at, updated_at)
VALUES
  (7, (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), '2026-06', 176.00, 25.00, 4400.00, 'pagado', '2026-06-30 10:00:00', NOW()),
  (7, (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), '2026-07', 76.50, 25.00, 1912.50, 'pendiente', '2026-07-10 10:00:00', NOW()),
  ((SELECT id FROM empleados WHERE dni = '70234567'), (SELECT id FROM obras WHERE codigo_obra = 'OB-MY-001'), '2026-06', 172.00, 22.00, 3784.00, 'pagado', '2026-06-30 10:00:00', NOW());

-- ════════════════════════════════════════════════════════════════
-- 14. MÉTODO DE PAGO (datos bancarios demo)
-- ════════════════════════════════════════════════════════════════

INSERT INTO metodo_pago (empleado_id, tipo, banco, numero_cuenta, cci, estado, created_at, updated_at)
VALUES
  (7, 'cuenta_corriente', 'BCP', '123-456-789', '002-123-456789012345-67', 'activo', NOW(), NOW()),
  ((SELECT id FROM empleados WHERE dni = '70234567'), 'ahorros', 'Interbank', '987-654-321', '003-987-654321098765-43', 'activo', NOW(), NOW());

-- ════════════════════════════════════════════════════════════════
-- 15. SOLICITUDES (empleados → empresa MarcaYA)
-- ════════════════════════════════════════════════════════════════

INSERT INTO solicitudes (empleado_id, empresa_id, estado, created_at, updated_at)
VALUES
  -- Juan Carlos: solicitud aceptada hace 1 mes
  (7, 6, 'aprobada', '2026-06-01 09:00:00', '2026-06-02 10:00:00'),
  -- María García: solicitud aceptada
  ((SELECT id FROM empleados WHERE dni = '70234567'), 6, 'aprobada', '2026-06-03 08:30:00', '2026-06-04 09:00:00'),
  -- Carlos Rodríguez: solicitud aceptada
  ((SELECT id FROM empleados WHERE dni = '70345678'), 6, 'aprobada', '2026-06-08 14:00:00', '2026-06-09 08:00:00'),
  -- Ana Martínez: solicitud aceptada
  ((SELECT id FROM empleados WHERE dni = '70456789'), 6, 'aprobada', '2026-06-10 10:00:00', '2026-06-11 09:30:00'),
  -- Pedro Sánchez: solicitud pendiente (recién enviada)
  ((SELECT id FROM empleados WHERE dni = '70567890'), 6, 'pendiente', '2026-07-12 16:00:00', '2026-07-12 16:00:00'),
  -- Lucía Fernández: solicitud aceptada
  ((SELECT id FROM empleados WHERE dni = '70678901'), 6, 'aprobada', '2026-06-15 11:00:00', '2026-06-16 08:00:00'),
  -- Roberto Díaz: solicitud pendiente
  ((SELECT id FROM empleados WHERE dni = '70789012'), 6, 'pendiente', '2026-07-13 09:00:00', '2026-07-13 09:00:00');

-- ════════════════════════════════════════════════════════════════
-- VERIFICACIÓN FINAL
-- ════════════════════════════════════════════════════════════════

-- Verificar datos insertados
SELECT '=== RESUMEN DE DATOS DEMO ===' AS info;
SELECT COUNT(*) AS total_usuarios FROM usuarios;
SELECT COUNT(*) AS total_empleados FROM empleados;
SELECT COUNT(*) AS total_empresas FROM empresas;
SELECT COUNT(*) AS total_obras FROM obras;
SELECT COUNT(*) AS total_paradas FROM paradas;
SELECT COUNT(*) AS total_asignaciones FROM asignaciones;
SELECT COUNT(*) AS total_registro_asistencias FROM registro_asistencias;
SELECT COUNT(*) AS total_asistencias FROM asistencias;
SELECT COUNT(*) AS total_valoraciones FROM valoraciones;
SELECT COUNT(*) AS total_solicitudes FROM solicitudes;
SELECT COUNT(*) AS total_cronograma_pagos FROM cronograma_de_pagos;

-- Verificar empleado 7
SELECT '=== EMPLEADO 7: ASISTENCIAS ===' AS info;
SELECT ra.fecha_hora, ra.tipo_marcacion, p.nombre AS parada, ra.valida_gps, ra.duracion_jornada
FROM registro_asistencias ra
JOIN paradas p ON p.id = ra.parada_id
WHERE ra.empleado_id = 7
ORDER BY ra.fecha_hora DESC
LIMIT 20;
