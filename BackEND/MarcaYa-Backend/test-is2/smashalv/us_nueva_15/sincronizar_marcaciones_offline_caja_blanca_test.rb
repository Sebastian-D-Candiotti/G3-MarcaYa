# frozen_string_literal: true

require_relative "../test_helper"

require "time"

module Application
  module UseCases
    module Asistencias
      class SincronizarMarcacionesOfflineCajaBlancaTest < Minitest::Test
        RegistroFake = Struct.new(:id, :tipo_marcacion, :fecha_hora, keyword_init: true)

        class EmpleadoRepoFake
          attr_reader :consultas

          def initialize
            @consultas = []
          end

          def find_by_id!(empleado_id)
            @consultas << empleado_id
            Object.new
          end
        end

        class AsistenciaRepoFake
          attr_reader :consultas

          def initialize(duplicado: nil, error: nil)
            @duplicado = duplicado
            @error = error
            @consultas = []
          end

          def find_by_cliente_marcacion_id(cliente_id)
            @consultas << cliente_id
            raise @error if @error

            @duplicado
          end
        end

        class CrearRegistroProbe < SincronizarMarcacionesOffline
          def initialize(creation:, **dependencies)
            @creation = creation
            super(**dependencies)
          end

          private

          def crear_registro!(empleado_id, marcacion, cliente_id)
            @creation.call(empleado_id, marcacion, cliente_id)
          end
        end

        class MarcadorFake
          attr_reader :llamadas

          def initialize(tipo)
            @tipo = tipo
            @llamadas = []
          end

          def ejecutar(**params)
            @llamadas << params
            RegistroFake.new(
              id: @llamadas.length,
              tipo_marcacion: @tipo,
              fecha_hora: params[:fecha_hora]
            )
          end
        end

        class TipoMarcacionProbe < SincronizarMarcacionesOffline
          def initialize(entrada:, salida:, **dependencies)
            @entrada = entrada
            @salida = salida
            super(**dependencies)
          end

          private

          def marcar_entrada
            @entrada
          end

          def marcar_salida
            @salida
          end
        end

        def test_cb15a_01_lote_vacio_no_ingresa_al_bucle
          caso = construir_orquestador

          resultado = caso[:use_case].ejecutar(empleado_id: 7, marcaciones: [])

          assert_equal({ sincronizados: [], duplicados: [], fallidos: [] }, resultado)
          assert_equal [ 7 ], caso[:empleado_repo].consultas
          assert_empty caso[:asistencia_repo].consultas
        end

        def test_cb15a_02_cliente_marcacion_id_vacio_se_clasifica_como_fallido
          caso = construir_orquestador

          resultado = caso[:use_case].ejecutar(empleado_id: 7, marcaciones: [ {} ])

          assert_empty resultado[:sincronizados]
          assert_empty resultado[:duplicados]
          assert_equal 1, resultado[:fallidos].length
          assert_match(/cliente_marcacion_id es obligatorio/, resultado[:fallidos][0][:error])
          assert_empty caso[:asistencia_repo].consultas
        end

        def test_cb15a_03_identificador_existente_se_clasifica_como_duplicado
          duplicado = registro(tipo: "ENTRADA")
          caso = construir_orquestador(duplicado: duplicado)

          resultado = caso[:use_case].ejecutar(
            empleado_id: 7,
            marcaciones: [ { cliente_marcacion_id: "offline-duplicado" } ]
          )

          assert_empty resultado[:sincronizados]
          assert_empty resultado[:fallidos]
          assert_equal [ "offline-duplicado" ], resultado[:duplicados].map { |item| item[:cliente_marcacion_id] }
        end

        def test_cb15a_04_registro_nuevo_se_clasifica_como_sincronizado
          caso = construir_orquestador(creation: ->(*) { registro(tipo: "ENTRADA") })

          resultado = caso[:use_case].ejecutar(
            empleado_id: 7,
            marcaciones: [ { cliente_marcacion_id: "offline-nuevo" } ]
          )

          assert_equal [ "offline-nuevo" ], resultado[:sincronizados].map { |item| item[:cliente_marcacion_id] }
          assert_empty resultado[:duplicados]
          assert_empty resultado[:fallidos]
        end

        def test_cb15a_05_error_de_dominio_se_aisla_como_fallido
          creation = lambda do |*|
            raise Domain::Errors::ValidacionError, "datos de marcacion invalidos"
          end
          caso = construir_orquestador(creation: creation)

          resultado = caso[:use_case].ejecutar(
            empleado_id: 7,
            marcaciones: [ { cliente_marcacion_id: "offline-dominio" } ]
          )

          assert_equal 1, resultado[:fallidos].length
          assert_equal "datos de marcacion invalidos", resultado[:fallidos][0][:error]
          assert_empty resultado[:sincronizados]
        end

        def test_cb15a_06_error_inesperado_se_aisla_como_fallido
          caso = construir_orquestador(error: StandardError.new("repositorio no disponible"))

          resultado = caso[:use_case].ejecutar(
            empleado_id: 7,
            marcaciones: [ { cliente_marcacion_id: "offline-error" } ]
          )

          assert_equal 1, resultado[:fallidos].length
          assert_equal "repositorio no disponible", resultado[:fallidos][0][:error]
          assert_empty resultado[:sincronizados]
        end

        def test_cb15b_01_tipo_entrada_preserva_la_hora_original
          caso = construir_selector_tipo
          fecha = "2026-07-13T08:15:30-05:00"

          resultado = caso[:use_case].ejecutar(
            empleado_id: 7,
            marcaciones: [ marcacion(tipo: "ENTRADA", fecha: fecha) ]
          )

          assert_equal 1, resultado[:sincronizados].length
          assert_equal Time.iso8601(fecha), caso[:entrada].llamadas[0][:fecha_hora]
          assert_empty caso[:salida].llamadas
          assert_empty resultado[:fallidos]
        end

        def test_cb15b_02_tipo_salida_preserva_la_hora_original
          caso = construir_selector_tipo
          fecha = "2026-07-13T18:05:00-05:00"

          resultado = caso[:use_case].ejecutar(
            empleado_id: 7,
            marcaciones: [ marcacion(tipo: "SALIDA", fecha: fecha) ]
          )

          assert_equal 1, resultado[:sincronizados].length
          assert_equal Time.iso8601(fecha), caso[:salida].llamadas[0][:fecha_hora]
          assert_empty caso[:entrada].llamadas
          assert_empty resultado[:fallidos]
        end

        def test_cb15b_03_tipo_desconocido_toma_la_rama_de_validacion
          caso = construir_selector_tipo

          resultado = caso[:use_case].ejecutar(
            empleado_id: 7,
            marcaciones: [ marcacion(tipo: "PAUSA") ]
          )

          assert_equal 1, resultado[:fallidos].length
          assert_match(/ENTRADA o SALIDA/, resultado[:fallidos][0][:error])
          assert_empty caso[:entrada].llamadas
          assert_empty caso[:salida].llamadas
        end

        def test_cb15b_04_fecha_vacia_toma_la_rama_obligatoria
          caso = construir_selector_tipo

          resultado = caso[:use_case].ejecutar(
            empleado_id: 7,
            marcaciones: [ marcacion(tipo: "ENTRADA", fecha: " ") ]
          )

          assert_equal 1, resultado[:fallidos].length
          assert_match(/fecha_hora_original es obligatoria/, resultado[:fallidos][0][:error])
          assert_empty caso[:entrada].llamadas
        end

        def test_cb15b_05_fecha_malformada_toma_la_rama_de_rescate
          caso = construir_selector_tipo

          resultado = caso[:use_case].ejecutar(
            empleado_id: 7,
            marcaciones: [ marcacion(tipo: "ENTRADA", fecha: "13/07/2026 08:15") ]
          )

          assert_equal 1, resultado[:fallidos].length
          assert_match(/ISO8601 valido/, resultado[:fallidos][0][:error])
          assert_empty caso[:entrada].llamadas
        end

        private

        def construir_orquestador(duplicado: nil, error: nil, creation: nil)
          empleado_repo = EmpleadoRepoFake.new
          asistencia_repo = AsistenciaRepoFake.new(duplicado: duplicado, error: error)
          use_case = CrearRegistroProbe.new(
            creation: creation || ->(*) { registro(tipo: "ENTRADA") },
            **dependencias(empleado_repo: empleado_repo, asistencia_repo: asistencia_repo)
          )

          { use_case: use_case, empleado_repo: empleado_repo, asistencia_repo: asistencia_repo }
        end

        def construir_selector_tipo
          empleado_repo = EmpleadoRepoFake.new
          asistencia_repo = AsistenciaRepoFake.new
          entrada = MarcadorFake.new("ENTRADA")
          salida = MarcadorFake.new("SALIDA")
          use_case = TipoMarcacionProbe.new(
            entrada: entrada,
            salida: salida,
            **dependencias(empleado_repo: empleado_repo, asistencia_repo: asistencia_repo)
          )

          { use_case: use_case, entrada: entrada, salida: salida }
        end

        def dependencias(empleado_repo:, asistencia_repo:)
          {
            asistencia_repo: asistencia_repo,
            empleado_repo: empleado_repo,
            parada_repo: Object.new,
            empleado_parada_repo: Object.new,
            gps_service: Object.new
          }
        end

        def registro(tipo:)
          RegistroFake.new(
            id: 99,
            tipo_marcacion: tipo,
            fecha_hora: Time.iso8601("2026-07-13T13:15:30Z")
          )
        end

        def marcacion(tipo:, fecha: "2026-07-13T08:15:30-05:00")
          {
            cliente_marcacion_id: "offline-#{tipo.downcase}",
            tipo_marcacion: tipo,
            parada_id: 15,
            latitud: -12.0464,
            longitud: -77.0428,
            fecha_hora_original: fecha,
            is_mocked: false
          }
        end
      end
    end
  end
end
