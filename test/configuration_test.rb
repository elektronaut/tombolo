# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    Tombolo.reset!
  end

  def test_default_server_bundles
    assert_equal({ default: "app/assets/builds/prerender.js" },
                 Tombolo.configuration.server_bundles)
  end

  def test_default_camelize_props
    assert_not Tombolo.configuration.camelize_props
  end

  def test_server_bundle_setter_sets_default_bundle
    Tombolo.configure do |config|
      config.server_bundle = "custom/path.js"
    end

    assert_equal "custom/path.js", Tombolo.configuration.server_bundles[:default]
  end

  def test_named_bundles
    Tombolo.configuration.server_bundles[:pages] = "lib/pages/prerender.js"

    assert_equal "lib/pages/prerender.js", Tombolo.configuration.server_bundles[:pages]
    assert_equal "app/assets/builds/prerender.js", Tombolo.configuration.server_bundles[:default]
  end
end
