# frozen_string_literal: true

require_relative "../test_helper"

class EmpresaTest < ActiveSupport::TestCase
  def setup
    usuario = Usuario.create!(correo: "test_#{SecureRandom.hex}@test.com", clave_hash: "hash", rol: "empresa")
    @empresa_valida = Empresa.new(ruc: "20111111111", nombre_empresa: "Constructora Test", usuario_id: usuario.id)
  end

  test "debería ser válida con un RUC de 11 dígitos numéricos" do
    assert @empresa_valida.valid?
  end

  test "debería ser inválida si el RUC no tiene 11 dígitos" do
    @empresa_valida.ruc = "2012345"
    assert_not @empresa_valida.valid?
    assert_includes @empresa_valida.errors[:ruc], "debe tener 11 dígitos numéricos"
  end

  test "debería ser inválida si el RUC contiene caracteres no numéricos" do
    @empresa_valida.ruc = "20A23456789"
    assert_not @empresa_valida.valid?
    assert_includes @empresa_valida.errors[:ruc], "solo se permiten caracteres numéricos"
  end

  test "debería ser inválida si el RUC ya está registrado" do
    @empresa_valida.save
    usuario2 = Usuario.create!(correo: "test_#{SecureRandom.hex}@test.com", clave_hash: "hash", rol: "empresa")
    empresa_duplicada = Empresa.new(ruc: "20111111111", nombre_empresa: "Otra Empresa", usuario_id: usuario2.id)
    
    assert_not empresa_duplicada.valid?
    assert_includes empresa_duplicada.errors[:ruc], "ya está en uso"
  end
end
