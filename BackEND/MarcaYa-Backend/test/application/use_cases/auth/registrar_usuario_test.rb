# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../../app/domain/entities/usuario"
require_relative "../../../../app/domain/entities/empleado"
require_relative "../../../../app/domain/entities/empresa"
require_relative "../../../../app/domain/entities/sunat_empresa"
require_relative "../../../../app/domain/value_objects/rol_usuario"
require_relative "../../../../app/domain/errors"
require_relative "../../../../app/domain/services/sunat_service"
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
              estado: u.estado,
              estado_verificacion: u.estado_verificacion,
              codigo_verificacion_digest: u.codigo_verificacion_digest,
              codigo_verificacion_expira_en: u.codigo_verificacion_expira_en
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

        def repo_empresa(codigo_valido: "123456")
          r = Object.new
          r.define_singleton_method(:guardar) { |e| e }
          r.define_singleton_method(:exists_by_ruc?) { |_ruc| false }
          r.define_singleton_method(:verificar_codigo_ruc?) { |_ruc, code| code == codigo_valido }
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

        def verification_code_service
          s = Object.new
          s.define_singleton_method(:generate) { "123456" }
          s.define_singleton_method(:digest) { |codigo| "digest-#{codigo}" }
          s.define_singleton_method(:expires_at) { Time.now + 600 }
          s
        end

        def verification_mailer
          delivery = Object.new
          delivery.define_singleton_method(:deliver_now) { true }

          message = Object.new
          message.define_singleton_method(:codigo_verificacion) { delivery }

          mailer = Object.new
          mailer.define_singleton_method(:with) { |_| message }
          mailer
        end

        def build_use_case(usuario_repo: repo_usuario_sin_correo,
                           empleado_repo: repo_empleado,
                           empresa_repo: repo_empresa)
          RegistrarUsuario.new(
            usuario_repo: usuario_repo,
            empleado_repo: empleado_repo,
            empresa_repo: empresa_repo,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service,
            verification_code_service: verification_code_service,
            verification_mailer: verification_mailer
          )
        end

        def test_ejecutar_returns_pending_usuario_for_empleado
          use_case = build_use_case

          result = use_case.ejecutar(
            correo: "nuevo@test.com",
            clave: "password123",
            rol: "empleado",
            nombre: "Juan",
            apellido: "Pérez"
          )

          assert_instance_of Domain::Entities::Usuario, result[:usuario]
          assert result[:requiere_verificacion]
          refute result[:usuario].activo?
          assert result[:usuario].pendiente_verificacion?
        end

        def test_ejecutar_raises_validacion_error_for_missing_fields
          use_case = build_use_case

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(correo: "", clave: "", rol: "", nombre: "")
          end
        end

        def test_ejecutar_raises_validacion_error_for_duplicate_email
          use_case = build_use_case(usuario_repo: repo_usuario_con_correo_existente)

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
          empresa_repo.define_singleton_method(:exists_by_ruc?) { |_ruc| false }
          empresa_repo.define_singleton_method(:verificar_codigo_ruc?) { |_ruc, code| true }

          use_case = build_use_case(empresa_repo: empresa_repo)

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
          empresa_repo_obj.define_singleton_method(:exists_by_ruc?) { |_ruc| false }
          empresa_repo_obj.define_singleton_method(:verificar_codigo_ruc?) { |_ruc, code| true }

          use_case = build_use_case(empleado_repo: empleado_repo, empresa_repo: empresa_repo_obj)

          use_case.ejecutar(
            correo: "admin@test.com",
            clave: "adminpass123",
            rol: "admin",
            nombre: "Admin"
          )

          refute empleado_guardado, "Should not create empleado for admin"
          refute empresa_guardada, "Should not create empresa for admin"
        end

        def test_ejecutar_manual_ruc_validations_fails_on_length
          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_sin_correo,
            empleado_repo: repo_empleado,
            empresa_repo: repo_empresa,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service,
            verification_code_service: verification_code_service,
            verification_mailer: verification_mailer
          )

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(
              correo: "empresa@test.com",
              clave: "password123",
              rol: "empresa",
              nombre: "Mi Empresa S.A.",
              ruc: "20123" # Too short
            )
          end
        end

        def test_ejecutar_manual_ruc_validations_fails_on_starting_digits
          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_sin_correo,
            empleado_repo: repo_empleado,
            empresa_repo: repo_empresa,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service,
            verification_code_service: verification_code_service,
            verification_mailer: verification_mailer
          )

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(
              correo: "empresa@test.com",
              clave: "password123",
              rol: "empresa",
              nombre: "Mi Empresa S.A.",
              ruc: "30123456789" # Doesn't start with 10 or 20
            )
          end
        end

        def test_ejecutar_manual_ruc_validations_fails_on_duplicate_ruc
          empresa_repo = Object.new
          empresa_repo.define_singleton_method(:exists_by_ruc?) { |_ruc| true }
          empresa_repo.define_singleton_method(:verificar_codigo_ruc?) { |_ruc, code| true }

          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_sin_correo,
            empleado_repo: repo_empleado,
            empresa_repo: empresa_repo,
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service,
            verification_code_service: verification_code_service,
            verification_mailer: verification_mailer
          )

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(
              correo: "empresa@test.com",
              clave: "password123",
              rol: "empresa",
              nombre: "Mi Empresa S.A.",
              ruc: "20123456789"
            )
          end
        end

        def test_ejecutar_sunat_verification_code_fails_with_invalid_code
          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_sin_correo,
            empleado_repo: repo_empleado,
            empresa_repo: repo_empresa(codigo_valido: "123456"),
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service,
            verification_code_service: verification_code_service,
            verification_mailer: verification_mailer
          )

          assert_raises Domain::Errors::ValidacionError do
            use_case.ejecutar(
              correo: "empresa@test.com",
              clave: "password123",
              rol: "empresa",
              ruc: "20100055237",
              registro_tipo: "sunat",
              codigo: "wrong"
            )
          end
        end

        def test_ejecutar_sunat_verification_code_succeeds_with_valid_code
          use_case = RegistrarUsuario.new(
            usuario_repo: repo_usuario_sin_correo,
            empleado_repo: repo_empleado,
            empresa_repo: repo_empresa(codigo_valido: "123456"),
            bcrypt_service: bcrypt_service,
            jwt_service: jwt_service,
            verification_code_service: verification_code_service,
            verification_mailer: verification_mailer
          )

          result = use_case.ejecutar(
            correo: "empresa@test.com",
            clave: "password123",
            rol: "empresa",
            ruc: "20100055237",
            registro_tipo: "sunat",
            codigo: "123456"
          )

          assert_instance_of Domain::Entities::Usuario, result[:usuario]
          assert result[:requiere_verificacion]
        end
      end
    end
  end
end
