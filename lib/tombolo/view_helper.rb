# frozen_string_literal: true

module Tombolo
  module ViewHelper
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::TextHelper

    def react_component(name, props: {}, prerender: false, camelize_props: nil)
      camelize = camelize_props.nil? ? Tombolo.configuration.camelize_props : camelize_props
      props = props.deep_transform_keys { |key| key.to_s.camelize(:lower) } if camelize

      props_json = props.to_json
      data = { react_component: name, react_props: props_json }
      content = prerender_content(name, props_json, prerender, data)

      content_tag(:div, content, data:)
    end

    private

    def prerender_content(name, props_json, prerender, data)
      return "" unless prerender

      data[:react_prerender] = ""
      renderer = Tombolo.renderer(prerender == true ? :default : prerender)
      renderer.render(name, props_json).html_safe # rubocop:disable Rails/OutputSafety
    end
  end
end
