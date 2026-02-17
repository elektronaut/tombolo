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
    def initialize(server_bundle:)
      @server_bundle = server_bundle
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
      raise "Tombolo server bundle not found: #{@server_bundle}" unless File.exist?(@server_bundle)

      console_polyfill + File.read(@server_bundle)
    end

    def console_polyfill
      "var console = { log: function(){}, warn: function(){}, error: function(){} };\n"
    end
  end
end
