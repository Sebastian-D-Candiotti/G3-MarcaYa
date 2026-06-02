# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/usuario"
require_relative "../../../../app/domain/entities/empleado"
require_relative "../../../../app/domain/entities/empresa"
require_relative "../../../../app/domain/value_objects/rol_usuario"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/application/use_cases/auth/registrar_usuario"

module Application
  module UseCases
    module Auth
      class RegistrarUsuarioTest < Minitest::Test
        def setup
          @usuario_guardado = Domain::Entities::Usuario.new(
            id: 10, correo: "nuevo@test.com",
            clave_hash: "$2a$12$hashedpassword",
            rol: "empleado", estado: true
          )
        end

        def repo_usuario_sin_correo
          r = Object.new
          r.define_singleton_method(:exists_by_correo?) { |_| false }
          r.define_singleton_method(:guardar) do |u|
            Domain::Entities::Usuario.new(
              id: 10, correo: u.correo,
              clave_hash: u.clave_hash, rol: u.rol.valor,
              estado: u.estado
            )
          end
          r
        end

        def repo_usuario_con_correo_existente
          r = Object.new
          r.define_singleton_method(:exists_by_correo?) { |_| true }
          r
        end

        def repo_empleado
          r = Object.new
          r.define_singleton_method(:guardar) { |e| e }
          r
        end

        def repo_empresa
          r = Object.new
          r.define_singleton_method(:guardar) { |e| e }
          r
        end

        def bcrypt_service
          s = Object.new
          s.define_singleton_method(:hash) { |_clave| "$2a$12$hashedpassword" }
          s
        end

        def jwt_service
          s = Object.new
          s.define_singleton_method(:encode) { |_| "fake.jwt.token" }
          s
        end

        def test_ejecutar_returns_usuario_and_token_for_empleado
          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_sin_correo,
            empleado_repo: repo_empleado,
            empresa_repo: repo_empresa,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service
          )

          result = use_case.ejecutar(
            correo: "nuevo@test.com",
            clave: "password123",
            rol: "empleado",
            nombre: "Juan",
            apellido: "Pérez"
          )

          assert_instance_of Domain::Entities::Usuario, result[:usuario]
          assert_equal "fake.jwt.token", result[:token]
        end

        def test_ejecutar_raises_validacion_error_for_missing_fields
          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_sin_correo,
            empleado_repo: repo_empleado,
            empresa_repo: repo_empresa,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service
          )

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(correo: "", clave: "", rol: "", nombre: "")
          end
        end

        def test_ejecutar_raises_validacion_error_for_duplicate_email
          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_con_correo_existente,
            empleado_repo: repo_empleado,
            empresa_repo: repo_empresa,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service
          )

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(
              correo: "existente@test.com",
              clave: "password123",
              rol: "empleado",
              nombre: "Juan"
            )
          end
        end

        def test_ejecutar_creates_empresa_record_when_rol_is_empresa
          empresa_guardada = nil
          empresa_repo = Object.new
          empresa_repo.define_singleton_method(:guardar) do |e|
            empresa_guardada = e
            e
          end

          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_sin_correo,
            empleado_repo: repo_empleado,
            empresa_repo: empresa_repo,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service
          )

          use_case.ejecutar(
            correo: "empresa@test.com",
            clave: "password123",
            rol: "empresa",
            nombre: "Mi Empresa S.A.",
            ruc: "20123456789"
          )

          assert_instance_of Domain::Entities::Empresa, empresa_guardada
          assert_equal "Mi Empresa S.A.", empresa_guardada.nombre_empresa
        end

        def test_ejecutar_does_not_create_profile_for_admin_role
          empleado_guardado = false
          empresa_guardada = false

          empleado_repo = Object.new
          empleado_repo.define_singleton_method(:guardar) { |_| empleado_guardado = true }
          empresa_repo_obj = Object.new
          empresa_repo_obj.define_singleton_method(:guardar) { |_| empresa_guardada = true }

          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_sin_correo,
            empleado_repo: empleado_repo,
            empresa_repo: empresa_repo_obj,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service
          )

          use_case.ejecutar(
            correo: "admin@test.com",
            clave: "adminpass123",
            rol: "admin",
            nombre: "Admin"
          )

          refute empleado_guardado, "Should not create empleado for admin"
          refute empresa_guardada, "Should not create empresa for admin"
        end
      end
    end
  end
end
