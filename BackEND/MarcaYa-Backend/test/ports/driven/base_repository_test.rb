# frozen_string_literal: true

require "minitest/autorun"
require_relative "../../../app/ports/driven/base_repository"

class Ports::Driven::BaseRepositoryTest < Minitest::Test
  def test_module_is_defined
    assert_instance_of Module, Ports::Driven::BaseRepository
  end

  def test_not_found_raises_standard_error
    assert_raises(StandardError) do
      Ports::Driven::BaseRepository.not_found!(1, "Usuario")
    end
  end

  def test_not_found_includes_id_in_message
    error = assert_raises(StandardError) do
      Ports::Driven::BaseRepository.not_found!(42, "Usuario")
    end
    assert_match(/42/, error.message)
    assert_match(/Usuario/, error.message)
  end

  def test_not_found_works_with_string_id
    error = assert_raises(StandardError) do
      Ports::Driven::BaseRepository.not_found!("abc-123", "Obra")
    end
    assert_match(/abc-123/, error.message)
    assert_match(/Obra/, error.message)
  end
end
