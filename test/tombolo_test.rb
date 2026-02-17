# frozen_string_literal: true

require "test_helper"
require "tempfile"

class TomboloTest < Minitest::Test
  def setup
    Tombolo.reset!
    @tempfiles = []
  end

  def teardown
    @tempfiles.each(&:unlink)
  end

  def test_renderer_creates_from_default_bundle
    Tombolo.configure do |config|
      config.server_bundle = create_temp_bundle(render_js("default"))
    end

    result = Tombolo.renderer.render("Test", "{}")

    assert_includes result, "default"
  end

  def test_renderer_creates_from_named_bundle
    Tombolo.configuration.server_bundles[:pages] = create_temp_bundle(render_js("pages"))

    result = Tombolo.renderer(:pages).render("Test", "{}")

    assert_includes result, "pages"
  end

  def test_renderer_raises_for_unknown_name
    assert_raises(ArgumentError) { Tombolo.renderer(:unknown) }
  end

  def test_named_renderers_are_isolated
    Tombolo.configuration.server_bundles[:alpha] = create_temp_bundle(render_js("alpha"))
    Tombolo.configuration.server_bundles[:beta] = create_temp_bundle(render_js("beta"))

    assert_includes Tombolo.renderer(:alpha).render("Test", "{}"), "alpha"
    assert_includes Tombolo.renderer(:beta).render("Test", "{}"), "beta"
  end

  def test_reset_clears_cached_renderers
    Tombolo.configuration.server_bundles[:pages] = create_temp_bundle(render_js("v1"))
    renderer_before = Tombolo.renderer(:pages)

    Tombolo.reset!
    Tombolo.configuration.server_bundles[:pages] = create_temp_bundle(render_js("v2"))

    assert_not renderer_before.equal?(Tombolo.renderer(:pages))
  end

  private

  def render_js(label)
    <<~JS
      function renderComponent(name, propsJson) {
        return "<span>#{label}</span>";
      }
    JS
  end

  def create_temp_bundle(content)
    file = Tempfile.new(["test_bundle", ".js"])
    file.write(content)
    file.close
    @tempfiles << file
    file.path
  end
end
