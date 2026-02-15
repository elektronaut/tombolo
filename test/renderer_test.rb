# frozen_string_literal: true

require "test_helper"
require "tempfile"

class RendererTest < Minitest::Test
  def setup
    Tombolo.reset!
    @tempfiles = []
  end

  def teardown
    @tempfiles.each(&:unlink)
  end

  def test_raises_on_missing_server_bundle
    Tombolo.configure do |config|
      config.server_bundle = "nonexistent.js"
    end

    require "tombolo/renderer"
    renderer = Tombolo::Renderer.new

    assert_raises(RuntimeError) { renderer.render("Greeting", "{}") }
  end

  def test_renders_component_via_execjs
    bundle = <<~JS
      function renderComponent(name, propsJson) {
        var props = JSON.parse(propsJson);
        return "<span>Hello " + (props.name || "World") + "</span>";
      }
    JS

    Tombolo.configure do |config|
      config.server_bundle = create_temp_bundle(bundle)
    end

    require "tombolo/renderer"
    renderer = Tombolo::Renderer.new
    result = renderer.render("Greeting", '{"name":"Tombolo"}')

    assert_includes result, "Hello Tombolo"
  end

  def test_thread_safety
    bundle = <<~JS
      function renderComponent(name, propsJson) {
        var props = JSON.parse(propsJson);
        return "<span>" + props.value + "</span>";
      }
    JS

    Tombolo.configure do |config|
      config.server_bundle = create_temp_bundle(bundle)
    end

    require "tombolo/renderer"
    renderer = Tombolo::Renderer.new

    threads = 10.times.map do |i|
      Thread.new do
        result = renderer.render("Test", JSON.generate(value: i))

        assert_includes result, i.to_s
      end
    end
    threads.each(&:join)
  end

  private

  def create_temp_bundle(content)
    file = Tempfile.new(["test_bundle", ".js"])
    file.write(content)
    file.close
    @tempfiles << file
    file.path
  end
end
