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

      content = ""
      if prerender
        data[:react_prerender] = ""
        content = Tombolo.renderer.render(name, props_json).html_safe # rubocop:disable Rails/OutputSafety
      end

      content_tag(:div, content, data:)
    end
  end
end
