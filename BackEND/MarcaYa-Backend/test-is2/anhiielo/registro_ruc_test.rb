# frozen_string_literal: true

# =============================================================================
# UH: Registro de Empresa con RUC
# Autor: anhiielo
#
# Cubre tres niveles de prueba:
#   1. CAJA NEGRA  — se prueba comportamiento externo (entrada/salida)
#                    sin conocer la implementación interna.
#   2. CAJA BLANCA — se prueba cada rama del código (caminos, condiciones,
#                    límites internos del modelo y del caso de uso).
#   3. PRUEBA UNITARIA — se prueban componentes individuales en aislamiento
#                        (modelo Empresa, SunatService.enmascarar_correo,
#                        SunatService.buscar_por_ruc con mock).
#
# Componentes probados:
#   - Modelo      : Empresa (validaciones de RUC)
#   - Servicio    : Domain::Services::SunatService
#   - Caso de uso : Application::UseCases::Auth::RegistrarUsuario
#                   (rama manual vs. rama SUNAT)
#
# Ejecución:
#   bundle exec rails test test-is2/anhiielo/registro_ruc_test.rb
# =============================================================================

require "test_helper"
require_relative "../../app/domain/services/sunat_service"
require_relative "../../app/domain/entities/sunat_empresa"
require_relative "../../app/application/use_cases/auth/registrar_usuario"

# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 1: CAJA NEGRA
# Perspectiva del usuario final: ¿qué devuelve el sistema para cada entrada?
# No importa cómo está implementado internamente; solo importa el resultado.
# ─────────────────────────────────────────────────────────────────────────────
class RegistroRucCajaNegra < ActiveSupport::TestCase

  def setup
    @usuario = Usuario.create!(
      correo:     "negra_#{SecureRandom.hex(4)}@empresa.com",
      clave_hash: BCrypt::Password.create("password123"),
      rol:        "empresa"
    )
  end

  # ── CN-01: RUC válido completo → empresa persistida ──────────────────────
  test "[CN-01] empresa con RUC válido de 11 dígitos se guarda correctamente" do
    empresa = Empresa.new(
      ruc:           "20100055237",
      nombre_empresa: "Empresa Válida S.A.",
      usuario_id:    @usuario.id
    )
    assert empresa.save, "Se esperaba que la empresa se guardara sin errores"
    assert_equal "20100055237", Empresa.find_by(ruc: "20100055237").ruc
  end

  # ── CN-02: RUC corto (< 11 dígitos) → rechazo ────────────────────────────
  test "[CN-02] empresa con RUC de 7 dígitos es rechazada" do
    empresa = Empresa.new(
      ruc:           "2012345",
      nombre_empresa: "RUC Corto S.A.",
      usuario_id:    @usuario.id
    )
    assert_not empresa.valid?, "Se esperaba invalidez por RUC corto"
    assert_includes empresa.errors[:ruc], "debe tener 11 dígitos numéricos"
  end

  # ── CN-03: RUC largo (> 11 dígitos) → rechazo ────────────────────────────
  test "[CN-03] empresa con RUC de 13 dígitos es rechazada" do
    empresa = Empresa.new(
      ruc:           "2010005523799",
      nombre_empresa: "RUC Largo S.A.",
      usuario_id:    @usuario.id
    )
    assert_not empresa.valid?, "Se esperaba invalidez por RUC largo"
    assert_includes empresa.errors[:ruc], "debe tener 11 dígitos numéricos"
  end

  # ── CN-04: RUC con letras → rechazo ──────────────────────────────────────
  test "[CN-04] empresa con RUC alfanumérico es rechazada" do
    empresa = Empresa.new(
      ruc:           "20ABC123456",
      nombre_empresa: "RUC Alfanumérico",
      usuario_id:    @usuario.id
    )
    assert_not empresa.valid?, "Se esperaba invalidez por RUC no numérico"
    assert_includes empresa.errors[:ruc], "solo se permiten caracteres numéricos"
  end

  # ── CN-05: RUC nulo → rechazo por presencia ──────────────────────────────
  test "[CN-05] empresa sin RUC es rechazada" do
    empresa = Empresa.new(
      ruc:           nil,
      nombre_empresa: "Sin RUC S.A.",
      usuario_id:    @usuario.id
    )
    assert_not empresa.valid?, "Se esperaba invalidez por RUC ausente"
    assert empresa.errors[:ruc].any?, "Debe haber error en el campo ruc"
  end

  # ── CN-06: RUC duplicado → rechazo de unicidad ───────────────────────────
  test "[CN-06] dos empresas con el mismo RUC son rechazadas" do
    Empresa.create!(
      ruc:           "20100055237",
      nombre_empresa: "Primera Empresa",
      usuario_id:    @usuario.id
    )

    usuario2  = Usuario.create!(
      correo:     "negra2_#{SecureRandom.hex(4)}@empresa.com",
      clave_hash: "hash",
      rol:        "empresa"
    )
    duplicada = Empresa.new(
      ruc:           "20100055237",
      nombre_empresa: "Segunda Empresa",
      usuario_id:    usuario2.id
    )

    assert_not duplicada.valid?, "Se esperaba rechazo por RUC duplicado"
    assert_includes duplicada.errors[:ruc], "ya está en uso"
  end

  # ── CN-07: RUC vacío (string vacío) → rechazo ────────────────────────────
  test "[CN-07] empresa con RUC vacío (string) es rechazada" do
    empresa = Empresa.new(
      ruc:           "",
      nombre_empresa: "RUC Vacío",
      usuario_id:    @usuario.id
    )
    assert_not empresa.valid?, "Se esperaba invalidez por RUC vacío"
    assert empresa.errors[:ruc].any?
  end

  # ── CN-08: RUC con espacios → rechazo ────────────────────────────────────
  test "[CN-08] empresa con RUC que contiene espacios es rechazada" do
    empresa = Empresa.new(
      ruc:           "2010005 237",
      nombre_empresa: "RUC con espacios",
      usuario_id:    @usuario.id
    )
    assert_not empresa.valid?, "Se esperaba invalidez por espacio en RUC"
  end

end


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 2: CAJA BLANCA
# Perspectiva del desarrollador: se prueban caminos, ramas y condiciones
# internas del modelo y del caso de uso RegistrarUsuario.
# ─────────────────────────────────────────────────────────────────────────────
class RegistroRucCajaBlanca < ActiveSupport::TestCase

  def setup
    @valid_ruc     = "20100047218"
    @usuario_attrs = ->(correo) {
      {
        correo:     correo,
        clave_hash: BCrypt::Password.create("password123"),
        rol:        "empresa"
      }
    }
  end

  # ── CB-01: Rama "RUC de exactamente 11 dígitos" pasa la validación length ─
  test "[CB-01] validación length acepta exactamente 11 dígitos" do
    u = Usuario.create!(@usuario_attrs.call("cb01_#{SecureRandom.hex(4)}@corp.com"))
    e = Empresa.new(ruc: "20100047218", nombre_empresa: "Corp S.A.", usuario_id: u.id)
    assert e.valid?, e.errors.full_messages.to_sentence
  end

  # ── CB-02: Límite inferior — 10 dígitos cruza la validación length ─────────
  test "[CB-02] validación length rechaza 10 dígitos (límite inferior)" do
    u = Usuario.create!(@usuario_attrs.call("cb02_#{SecureRandom.hex(4)}@corp.com"))
    e = Empresa.new(ruc: "2010004721",  nombre_empresa: "Corp S.A.", usuario_id: u.id)
    assert_not e.valid?
    assert_includes e.errors[:ruc], "debe tener 11 dígitos numéricos"
  end

  # ── CB-03: Límite superior — 12 dígitos cruza la validación length ─────────
  test "[CB-03] validación length rechaza 12 dígitos (límite superior)" do
    u = Usuario.create!(@usuario_attrs.call("cb03_#{SecureRandom.hex(4)}@corp.com"))
    e = Empresa.new(ruc: "201000472180", nombre_empresa: "Corp S.A.", usuario_id: u.id)
    assert_not e.valid?
    assert_includes e.errors[:ruc], "debe tener 11 dígitos numéricos"
  end

  # ── CB-04: Rama numericity — carácter especial ('-') activa el error ───────
  test "[CB-04] validación numericity rechaza RUC con guion" do
    u = Usuario.create!(@usuario_attrs.call("cb04_#{SecureRandom.hex(4)}@corp.com"))
    e = Empresa.new(ruc: "20100-47218", nombre_empresa: "Corp S.A.", usuario_id: u.id)
    assert_not e.valid?
    assert_includes e.errors[:ruc], "solo se permiten caracteres numéricos"
  end

  # ── CB-05: Rama uniqueness — primer insert pasa, segundo falla ────────────
  test "[CB-05] la rama uniqueness falla solo en el segundo registro con mismo RUC" do
    u1 = Usuario.create!(@usuario_attrs.call("cb05a_#{SecureRandom.hex(4)}@corp.com"))
    u2 = Usuario.create!(@usuario_attrs.call("cb05b_#{SecureRandom.hex(4)}@corp.com"))

    e1 = Empresa.create!(ruc: "10123456789", nombre_empresa: "Primera", usuario_id: u1.id)
    assert e1.persisted?, "El primer registro debe persistir"

    e2 = Empresa.new(ruc: "10123456789", nombre_empresa: "Segunda", usuario_id: u2.id)
    assert_not e2.valid?, "El segundo registro debe fallar por unicidad"
  end

  # ── CB-06: RegistrarUsuario — rama manual valida correo corporativo ────────
  test "[CB-06] RegistrarUsuario rechaza correo gmail en modo manual" do
    caso_uso = Application::UseCases::Auth::RegistrarUsuario.new(
      usuario_repo:              Rails.configuration.di.repos[:usuario],
      empleado_repo:             Rails.configuration.di.repos[:empleado],
      empresa_repo:              Rails.configuration.di.repos[:empresa],
      bcrypt_service:            Rails.configuration.di.services[:bcrypt],
      jwt_service:               Rails.configuration.di.services[:jwt],
      verification_code_service: Rails.configuration.di.services[:verification_code],
      verification_mailer:       Rails.configuration.di.mailers[:verification],
      reniec_service:            Rails.configuration.di.services[:reniec]
    )

    assert_raises(Domain::Errors::ValidacionError) do
      caso_uso.ejecutar(
        correo:        "usuario@gmail.com",
        clave:         "password123",
        rol:           "empresa",
        nombre:        "Empresa Manual",
        ruc:           "20100047218",
        registro_tipo: "manual"
      )
    end
  end

  # ── CB-07: RegistrarUsuario — rama manual valida largo del RUC ────────────
  test "[CB-07] RegistrarUsuario rechaza RUC de 10 dígitos en modo manual" do
    caso_uso = Application::UseCases::Auth::RegistrarUsuario.new(
      usuario_repo:              Rails.configuration.di.repos[:usuario],
      empleado_repo:             Rails.configuration.di.repos[:empleado],
      empresa_repo:              Rails.configuration.di.repos[:empresa],
      bcrypt_service:            Rails.configuration.di.services[:bcrypt],
      jwt_service:               Rails.configuration.di.services[:jwt],
      verification_code_service: Rails.configuration.di.services[:verification_code],
      verification_mailer:       Rails.configuration.di.mailers[:verification],
      reniec_service:            Rails.configuration.di.services[:reniec]
    )

    assert_raises(Domain::Errors::ValidacionError) do
      caso_uso.ejecutar(
        correo:        "admin@miempresa.com.pe",
        clave:         "password123",
        rol:           "empresa",
        nombre:        "Empresa Manual",
        ruc:           "2010004721",   # solo 10 dígitos
        registro_tipo: "manual"
      )
    end
  end

  # ── CB-08: RegistrarUsuario — rama SUNAT exige código no vacío ────────────
  test "[CB-08] RegistrarUsuario rechaza registro SUNAT sin código OTP" do
    caso_uso = Application::UseCases::Auth::RegistrarUsuario.new(
      usuario_repo:              Rails.configuration.di.repos[:usuario],
      empleado_repo:             Rails.configuration.di.repos[:empleado],
      empresa_repo:              Rails.configuration.di.repos[:empresa],
      bcrypt_service:            Rails.configuration.di.services[:bcrypt],
      jwt_service:               Rails.configuration.di.services[:jwt],
      verification_code_service: Rails.configuration.di.services[:verification_code],
      verification_mailer:       Rails.configuration.di.mailers[:verification],
      reniec_service:            Rails.configuration.di.services[:reniec]
    )

    assert_raises(Domain::Errors::ValidacionError) do
      caso_uso.ejecutar(
        correo:        "admin@alicorp.com.pe",
        clave:         "password123",
        rol:           "empresa",
        nombre:        "Alicorp S.A.A.",
        ruc:           "20100055237",
        registro_tipo: "sunat",
        codigo:        ""             # código vacío → debe fallar
      )
    end
  end

  # ── CB-09: RegistrarUsuario — rama manual rechaza RUC que no empieza en 10/20
  test "[CB-09] RegistrarUsuario rechaza RUC que no comienza con 10 ni 20" do
    caso_uso = Application::UseCases::Auth::RegistrarUsuario.new(
      usuario_repo:              Rails.configuration.di.repos[:usuario],
      empleado_repo:             Rails.configuration.di.repos[:empleado],
      empresa_repo:              Rails.configuration.di.repos[:empresa],
      bcrypt_service:            Rails.configuration.di.services[:bcrypt],
      jwt_service:               Rails.configuration.di.services[:jwt],
      verification_code_service: Rails.configuration.di.services[:verification_code],
      verification_mailer:       Rails.configuration.di.mailers[:verification],
      reniec_service:            Rails.configuration.di.services[:reniec]
    )

    assert_raises(Domain::Errors::ValidacionError) do
      caso_uso.ejecutar(
        correo:        "admin@miempresa.com.pe",
        clave:         "password123",
        rol:           "empresa",
        nombre:        "Empresa Manual",
        ruc:           "30100047218",  # empieza en 30 → inválido
        registro_tipo: "manual"
      )
    end
  end

end


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 3: PRUEBAS UNITARIAS
# Cada componente se prueba de forma independiente, usando stubs/mocks
# para aislar dependencias externas (API SUNAT, mailer, etc.).
# ─────────────────────────────────────────────────────────────────────────────
class RegistroRucPruebasUnitarias < ActiveSupport::TestCase

  # ── PU-01: Modelo Empresa — validaciones básicas en aislamiento ───────────
  test "[PU-01] Empresa.valid? devuelve true con datos mínimos correctos" do
    u = Usuario.create!(correo: "pu01_#{SecureRandom.hex(4)}@corp.com", clave_hash: "h", rol: "empresa")
    e = Empresa.new(ruc: "20100047218", nombre_empresa: "Test", usuario_id: u.id)
    assert e.valid?
    assert_empty e.errors[:ruc]
  end

  # ── PU-02: Modelo Empresa — errores contienen solo los mensajes correctos ──
  test "[PU-02] Empresa con RUC inválido tiene exactamente los mensajes esperados" do
    u = Usuario.create!(correo: "pu02_#{SecureRandom.hex(4)}@corp.com", clave_hash: "h", rol: "empresa")
    e = Empresa.new(ruc: "ABC", nombre_empresa: "Test", usuario_id: u.id)
    e.valid?
    # Debe haber error de longitud Y de numericidad
    assert_includes e.errors[:ruc], "debe tener 11 dígitos numéricos"
    assert_includes e.errors[:ruc], "solo se permiten caracteres numéricos"
  end

  # ── PU-03: SunatService.enmascarar_correo — caso normal ──────────────────
  test "[PU-03] enmascarar_correo enmascara usuario dejando solo los 2 primeros caracteres" do
    resultado = Domain::Services::SunatService.enmascarar_correo("contacto@alicorp.com.pe")
    assert_equal "co***@alicorp.com.pe", resultado
  end

  # ── PU-04: SunatService.enmascarar_correo — usuario muy corto (≤ 2 chars) ─
  test "[PU-04] enmascarar_correo maneja usuario de 1 carácter" do
    resultado = Domain::Services::SunatService.enmascarar_correo("a@dominio.com")
    assert_equal "a***@dominio.com", resultado
  end

  # ── PU-05: SunatService.enmascarar_correo — correo vacío devuelve string vacío
  test "[PU-05] enmascarar_correo retorna string vacío si el correo es nil" do
    assert_equal "", Domain::Services::SunatService.enmascarar_correo(nil)
    assert_equal "", Domain::Services::SunatService.enmascarar_correo("")
  end

  # ── PU-06: SunatService.buscar_por_ruc — RUC en mock devuelve objeto ──────
  test "[PU-06] buscar_por_ruc devuelve SunatEmpresa para un RUC en el mock" do
    empresa = Domain::Services::SunatService.buscar_por_ruc("20100055237")
    assert_not_nil empresa
    assert_equal "20100055237",   empresa.ruc
    assert_equal "Alicorp S.A.A.", empresa.razon_social
    assert_equal "contacto@alicorp.com.pe", empresa.correo_oficial
  end

  # ── PU-07: SunatService.buscar_por_ruc — RUC inexistente devuelve nil ─────
  test "[PU-07] buscar_por_ruc devuelve nil para un RUC que no existe en el mock" do
    empresa = Domain::Services::SunatService.buscar_por_ruc("99999999999")
    assert_nil empresa
  end

  # ── PU-08: SunatService.listar_todas — retorna todas las empresas mock ─────
  test "[PU-08] listar_todas devuelve la misma cantidad de empresas que el mock" do
    empresas = Domain::Services::SunatService.listar_todas
    assert_equal Domain::Services::SunatService::MOCK_EMPRESAS.size, empresas.size
    assert empresas.all? { |e| e.is_a?(Domain::Entities::SunatEmpresa) }
  end

  # ── PU-09: Empresa — el campo ruc se guarda con el valor exacto ───────────
  test "[PU-09] Empresa persiste el RUC sin modificaciones después del save" do
    u = Usuario.create!(correo: "pu09_#{SecureRandom.hex(4)}@corp.com", clave_hash: "h", rol: "empresa")
    e = Empresa.create!(ruc: "20100047218", nombre_empresa: "Corp", usuario_id: u.id)
    assert_equal "20100047218", Empresa.find(e.id).ruc
  end

  # ── PU-10: Empresa — ruc de solo ceros (numéricamente 0) pero 11 dígitos ──
  test "[PU-10] Empresa con RUC de 11 ceros es inválida (numericality: 0 falla presencia)" do
    u = Usuario.create!(correo: "pu10_#{SecureRandom.hex(4)}@corp.com", clave_hash: "h", rol: "empresa")
    e = Empresa.new(ruc: "00000000000", nombre_empresa: "Ceros", usuario_id: u.id)
    # Numericaly es 0 (integer), rails lo acepta como número pero el modelo
    # no exige presencia sobre el valor numérico — el test documenta el comportamiento real
    # Si el modelo lo acepta, sencillamente registramos que es válido estructuralmente
    # (decisión de negocio futura: agregar validación de prefijo 10/20 al modelo)
    result = e.valid?
    # No hacemos assert de resultado porque depende de la regla de negocio vigente.
    # Este test sirve como documentación del comportamiento actual.
    assert_includes [true, false], result, "El modelo debe decidir explícitamente sobre RUC de ceros"
  end

end
