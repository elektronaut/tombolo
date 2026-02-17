# frozen_string_literal: true

require "test_helper"

class ViewHelperTest < Minitest::Test
  include Tombolo::ViewHelper
  include ActionView::Helpers::TagHelper

  attr_accessor :output_buffer

  def setup
    @output_buffer = ActionView::OutputBuffer.new
  end

  def test_renders_div_with_correct_data_attributes
    html = react_component("Greeting", props: { name: "World" })
    doc = Nokogiri::HTML.fragment(html)
    div = doc.at_css("div")

    assert_equal "Greeting", div["data-react-component"]
    assert_equal '{"name":"World"}', div["data-react-props"]
  end

  def test_renders_with_empty_props_when_none_given
    html = react_component("Greeting")
    doc = Nokogiri::HTML.fragment(html)
    div = doc.at_css("div")

    assert_equal "{}", div["data-react-props"]
  end

  def test_props_are_json_encoded
    html = react_component("Greeting", props: { items: [1, 2], nested: { a: "b" } })
    doc = Nokogiri::HTML.fragment(html)
    div = doc.at_css("div")
    props = JSON.parse(div["data-react-props"])

    assert_equal [1, 2], props["items"]
    assert_equal({ "a" => "b" }, props["nested"])
  end

  def test_camelizes_props_when_passed_as_argument
    html = react_component("Greeting", props: { first_name: "World" }, camelize_props: true)
    props = parse_props(html)

    assert_equal "World", props["firstName"]
    assert_nil props["first_name"]
  end

  def test_camelizes_nested_props
    html = react_component("Greeting", props: { user_info: { last_name: "Doe" } }, camelize_props: true)
    props = parse_props(html)

    assert_equal({ "lastName" => "Doe" }, props["userInfo"])
  end

  def test_camelizes_props_from_global_config
    Tombolo.configuration.camelize_props = true
    html = react_component("Greeting", props: { first_name: "World" })
    props = parse_props(html)

    assert_equal "World", props["firstName"]
  ensure
    Tombolo.reset!
  end

  def test_per_call_camelize_props_overrides_global_config
    Tombolo.configuration.camelize_props = true
    html = react_component("Greeting", props: { first_name: "World" }, camelize_props: false)
    props = parse_props(html)

    assert_equal "World", props["first_name"]
    assert_nil props["firstName"]
  ensure
    Tombolo.reset!
  end

  def test_renders_with_prerender
    mock_renderer = Minitest::Mock.new
    mock_renderer.expect(:render, "<span>Hello</span>", ["Greeting", '{"name":"World"}'])

    Tombolo.stub(:renderer, ->(_name = :default) { mock_renderer }) do
      html = react_component("Greeting", props: { name: "World" }, prerender: true)
      doc = Nokogiri::HTML.fragment(html)
      div = doc.at_css("div")

      assert div.key?("data-react-prerender")
      assert_equal "Greeting", div["data-react-component"]
      assert_includes div.inner_html, "<span>Hello</span>"
    end

    mock_renderer.verify
  end

  def test_renders_with_named_prerender_context
    mock_renderer = Minitest::Mock.new
    mock_renderer.expect(:render, "<span>Named</span>", ["ImageGrid", "{}"])

    renderer_stub = lambda { |name = :default|
      assert_equal :pages, name
      mock_renderer
    }

    Tombolo.stub(:renderer, renderer_stub) do
      html = react_component("ImageGrid", prerender: :pages)
      doc = Nokogiri::HTML.fragment(html)
      div = doc.at_css("div")

      assert div.key?("data-react-prerender")
      assert_includes div.inner_html, "<span>Named</span>"
    end

    mock_renderer.verify
  end

  private

  def parse_props(html)
    doc = Nokogiri::HTML.fragment(html)
    JSON.parse(doc.at_css("div")["data-react-props"])
  end
end
