# frozen_string_literal: true

# ─── Test Helper para Pruebas de IS2 — Recuperación de Contraseña ───
# Carpeta separada de test/ para no mezclar con pruebas del proyecto.
# Usa Minitest con mocks manuales (sin mocha/minitest-mock).

require "minitest/autorun"
require "time"
require "securerandom"
require "json"

# ── Active Support stub para ejecución standalone (sin Rails) ────
# Los use cases usan Time.current y *.minutes.from_now internamente.
# Necesitamos Numeric#minutes pero NO las time zones de ActiveSupport.

# 1) Cargar solo Numeric#minutes (para *.minutes.from_now)
require "active_support/core_ext/numeric/time"

# 2) Definir Time.current directamente (sin pasar por ActiveSupport::TimeZones)
#    Esto evita la dependencia de IsolatedExecutionState de AS 8.1+
class Time
  unless method_defined?(:current)
    def self.current
      Time.now
    end
  end
end

# ── Cargar dependencias del dominio y casos de uso ────────────────
require_relative "../app/domain/entities/usuario"
require_relative "../app/domain/value_objects/rol_usuario"
require_relative "../app/domain/errors"
require_relative "../app/application/use_cases/auth/solicitar_codigo_recuperacion"
require_relative "../app/application/use_cases/auth/verificar_codigo_recuperacion"
require_relative "../app/application/use_cases/auth/restablecer_contrasena"

# ── Stub del módulo Jwt (se usa en VerificarCodigoRecuperacion) ──
# El use case llama Jwt.encode directamente, así que necesitamos
# un stub que funcione sin Rails credentials.
module Jwt
  SECRET = "test-secret-key-for-is2"

  def self.encode(payload, exp = 24.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET, "HS256")
  end

  def self.decode(token)
    JWT.decode(token, SECRET, true, algorithm: "HS256").first
  end
end

# Cargar la gema jwt si está disponible
begin
  require "jwt"
rescue LoadError
  # Si jwt no está instalada, definimos un stub mínimo
  module JWT
    def self.encode(payload, _secret, _algorithm)
      # Stub: retorna un token fake que contiene el payload codificado
      payload.to_json
    end

    def self.decode(token, _secret, _verify, algorithm: nil)
      # Stub: decodifica el token fake
      [JSON.parse(token), {}]
    end
  end
end

module TestIs2
  # ── Helpers para construir mocks manuales ──────────────────────

  def build_usuario(
    id: 1,
    correo: "test@example.com",
    clave_hash: "$2a$12$fakehash",
    rol: "empleado",
    estado: true,
    codigo_recuperacion: nil,
    codigo_expira: nil,
    created_at: Time.current,
    updated_at: Time.current
  )
    Domain::Entities::Usuario.new(
      id: id,
      correo: correo,
      clave_hash: clave_hash,
      rol: rol,
      estado: estado,
      codigo_recuperacion: codigo_recuperacion,
      codigo_expira: codigo_expira,
      created_at: created_at,
      updated_at: updated_at
    )
  end

  # Mock de repositorio que retorna un usuario específico
  def build_usuario_repo(usuario)
    r = Object.new
    r.define_singleton_method(:find_by_correo) { |_correo| usuario }
    r.define_singleton_method(:find_by_id!) { |_id| usuario }
    r.define_singleton_method(:guardar) { |u| u }
    r
  end

  # Mock de repositorio que retorna nil (usuario no encontrado)
  def build_usuario_repo_vacio
    r = Object.new
    r.define_singleton_method(:find_by_correo) { |_correo| nil }
    r.define_singleton_method(:find_by_id!) { |_id| raise "Usuario no encontrado" }
    r.define_singleton_method(:guardar) { |u| u }
    r
  end

  # Mock de notificador de email (registra llamadas)
  def build_notificador
    state = { args: nil }
    n = Object.new
    n.define_singleton_method(:enviar_codigo) do |destino:, codigo:|
      state[:args] = { destino: destino, codigo: codigo }
    end
    n.define_singleton_method(:enviar_codigo_args) { state[:args] }
    n
  end

  # Mock de bcrypt service
  def build_bcrypt_service
    s = Object.new
    s.define_singleton_method(:hash) { |clave| "bcrypt_hash_of_#{clave}" }
    s
  end

  # Mock de jwt_service (no se usa internamente, pero el constructor lo pide)
  def build_jwt_service
    s = Object.new
    s.define_singleton_method(:encode) { |_payload| "fake-jwt-token" }
    s.define_singleton_method(:decode) { |_token| {} }
    s
  end
end
