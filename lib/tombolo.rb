# frozen_string_literal: true

require "tombolo/configuration"
require "tombolo/version"
require "tombolo/view_helper"
require "tombolo/railtie" if defined?(Rails::Railtie)

module Tombolo
  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def renderer(name = :default)
      @renderers ||= {}
      @renderers[name] ||= begin
        path = configuration.server_bundles[name]
        raise ArgumentError, "No server bundle configured for #{name.inspect}" unless path

        require "tombolo/renderer"
        Renderer.new(server_bundle: path)
      end
    end

    def reset!
      @configuration = nil
      @renderers = nil
    end
  end
end
