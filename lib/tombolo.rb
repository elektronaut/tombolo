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

    def renderer
      @renderer ||= begin
        require "tombolo/renderer"
        Renderer.new
      end
    end

    def reset!
      @configuration = nil
      @renderer = nil
    end
  end
end
