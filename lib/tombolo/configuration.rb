# frozen_string_literal: true

module Tombolo
  class Configuration
    attr_accessor :camelize_props, :server_bundle

    def initialize
      @camelize_props = false
      @server_bundle = "app/assets/builds/prerender.js"
    end
  end
end
