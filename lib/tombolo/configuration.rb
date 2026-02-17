# frozen_string_literal: true

module Tombolo
  class Configuration
    attr_accessor :camelize_props
    attr_reader :server_bundles

    def initialize
      @camelize_props = false
      @server_bundles = { default: "app/assets/builds/prerender.js" }
    end

    def server_bundle=(path)
      @server_bundles[:default] = path
    end
  end
end
