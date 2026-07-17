# frozen_string_literal: true

require_relative "../test_helper"

module Application
  module UseCases
    module Auth
      class VerificarCuentaCajaBlancaTest < Minitest::Test
        NOW = Time.utc(2026, 7, 13, 15, 0, 0)

        class UsuarioRepoFake
          attr_reader :busquedas, :guardados

          def initialize(usuario)
            @usuario = usuario
            @busquedas = []
            @guardados = []
          end

          def find_by_correo(correo)
            @busquedas << correo
            @usuario
          end

          def guardar(usuario)
            @guardados << usuario
            usuario
          end
        end

        class VerificationCodeServiceFake
          attr_reader :consultas

          def initialize(coincide:)
            @coincide = coincide
            @consultas = []
          end

          def matches?(codigo, digest)
            @consultas << [ codigo, digest ]
            @coincide
          end
        end

        def test_cb10_01_rechaza_correo_vacio_antes_de_consultar_repositorio
          caso = construir_caso(usuario: usuario_pendiente)

          assert_raises(Domain::Errors::ValidacionError) do
            caso[:use_case].ejecutar(correo: " ", codigo: "123456")
          end
          assert_empty caso[:repo].busquedas
          assert_empty caso[:service].consultas
        end

        def test_cb10_02_rechaza_codigo_vacio_por_segunda_condicion_del_cortocircuito
          caso = construir_caso(usuario: usuario_pendiente)

          assert_raises(Domain::Errors::ValidacionError) do
            caso[:use_case].ejecutar(correo: "busti@marcaya.test", codigo: "")
          end
          assert_empty caso[:repo].busquedas
          assert_empty caso[:service].consultas
        end

        def test_cb10_03_rechaza_codigo_con_formato_distinto_de_seis_digitos
          caso = construir_caso(usuario: usuario_pendiente)

          error = assert_raises(Domain::Errors::ValidacionError) do
            caso[:use_case].ejecutar(correo: "busti@marcaya.test", codigo: "12A456")
          end
          assert_match(/6 digitos/, error.message)
          assert_empty caso[:repo].busquedas
        end

        def test_cb10_04_rechaza_usuario_inexistente
          caso = construir_caso(usuario: nil)

          assert_raises(Domain::Errors::UsuarioNoEncontradoError) do
            caso[:use_case].ejecutar(correo: "ausente@marcaya.test", codigo: "123456")
          end
          assert_equal [ "ausente@marcaya.test" ], caso[:repo].busquedas
          assert_empty caso[:service].consultas
        end

        def test_cb10_05_rechaza_codigo_ya_usado
          caso = construir_caso(usuario: usuario_activo)

          assert_raises(Domain::Errors::CodigoVerificacionUsadoError) do
            caso[:use_case].ejecutar(correo: "activo@marcaya.test", codigo: "123456")
          end
          assert_empty caso[:service].consultas
          assert_empty caso[:repo].guardados
        end

        def test_cb10_06_rechaza_codigo_sin_fecha_de_expiracion
          caso = construir_caso(usuario: usuario_pendiente(expira_en: nil))

          assert_raises(Domain::Errors::CodigoVerificacionVencidoError) do
            caso[:use_case].ejecutar(correo: "busti@marcaya.test", codigo: "123456")
          end
          assert_empty caso[:service].consultas
          assert_empty caso[:repo].guardados
        end

        def test_cb10_07_rechaza_codigo_en_el_instante_exacto_de_expiracion
          caso = construir_caso(usuario: usuario_pendiente(expira_en: NOW))

          assert_raises(Domain::Errors::CodigoVerificacionVencidoError) do
            caso[:use_case].ejecutar(correo: "busti@marcaya.test", codigo: "123456")
          end
          assert_empty caso[:service].consultas
          assert_empty caso[:repo].guardados
        end

        def test_cb10_08_rechaza_codigo_vigente_que_no_coincide_con_el_digest
          caso = construir_caso(usuario: usuario_pendiente, coincide: false)

          assert_raises(Domain::Errors::CodigoVerificacionInvalidoError) do
            caso[:use_case].ejecutar(correo: "busti@marcaya.test", codigo: "654321")
          end
          assert_equal [ [ "654321", "digest-123456" ] ], caso[:service].consultas
          assert_empty caso[:repo].guardados
        end

        def test_cb10_09_activa_usuario_con_codigo_valido_y_vigente
          caso = construir_caso(usuario: usuario_pendiente)

          usuario = caso[:use_case].ejecutar(
            correo: "busti@marcaya.test",
            codigo: "123456"
          )

          assert usuario.activo?
          assert usuario.verificado?
          assert_equal NOW, usuario.verificado_en
          assert_nil usuario.codigo_verificacion_digest
          assert_nil usuario.codigo_verificacion_expira_en
          assert_equal [ usuario ], caso[:repo].guardados
          assert_equal [ [ "123456", "digest-123456" ] ], caso[:service].consultas
        end

        private

        def construir_caso(usuario:, coincide: true)
          repo = UsuarioRepoFake.new(usuario)
          service = VerificationCodeServiceFake.new(coincide: coincide)
          use_case = VerificarCuenta.new(
            usuario_repo: repo,
            verification_code_service: service,
            clock: -> { NOW }
          )

          { use_case: use_case, repo: repo, service: service }
        end

        def usuario_pendiente(expira_en: NOW + 600)
          Domain::Entities::Usuario.new(
            id: 10,
            correo: "busti@marcaya.test",
            clave_hash: "$2a$12$hash",
            rol: "empleado",
            estado: false,
            estado_verificacion: Domain::Entities::Usuario::ESTADO_VERIFICACION_PENDIENTE,
            codigo_verificacion_digest: "digest-123456",
            codigo_verificacion_expira_en: expira_en
          )
        end

        def usuario_activo
          Domain::Entities::Usuario.new(
            id: 11,
            correo: "activo@marcaya.test",
            clave_hash: "$2a$12$hash",
            rol: "empleado",
            estado: true,
            estado_verificacion: Domain::Entities::Usuario::ESTADO_VERIFICACION_ACTIVO,
            verificado_en: NOW - 60
          )
        end
      end
    end
  end
end
