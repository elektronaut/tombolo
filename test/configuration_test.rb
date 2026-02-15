# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    Tombolo.reset!
  end

  def test_default_server_bundle_path
    assert_equal "app/assets/builds/prerender.js",
                 Tombolo.configuration.server_bundle
  end

  def test_default_camelize_props
    assert_not Tombolo.configuration.camelize_props
  end

  def test_custom_configuration_via_block
    Tombolo.configure do |config|
      config.server_bundle = "custom/path.js"
    end

    assert_equal "custom/path.js", Tombolo.configuration.server_bundle
  end
end
