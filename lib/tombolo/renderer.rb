# frozen_string_literal: true

begin
  require "execjs"
rescue LoadError
  raise LoadError,
        "ExecJS is required for server-side rendering. " \
        "Add `gem \"execjs\"` to your Gemfile."
end

module Tombolo
  class Renderer
    def initialize
      @mutex = Mutex.new
      @context = nil
    end

    def render(name, props_json)
      @mutex.synchronize do
        context.call("renderComponent", name, props_json)
      end
    end

    private

    def context
      @context ||= ExecJS.compile(bundle_source)
    end

    def bundle_source
      path = Tombolo.configuration.server_bundle
      raise "Tombolo server bundle not found: #{path}" unless File.exist?(path)

      console_polyfill + File.read(path)
    end

    def console_polyfill
      "var console = { log: function(){}, warn: function(){}, error: function(){} };\n"
    end
  end
end
