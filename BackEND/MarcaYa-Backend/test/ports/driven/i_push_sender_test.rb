# frozen_string_literal: true

require "test_helper"

class Ports::Driven::IPushSenderTest < ActiveSupport::TestCase
  def setup_fixtures; end
  def teardown_fixtures; end

  test "enviar raises NotImplementedError" do
    assert_raises(NotImplementedError) { Ports::Driven::IPushSender.enviar(nil, nil) }
  end
end
