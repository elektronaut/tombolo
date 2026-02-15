# frozen_string_literal: true

module Tombolo
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Creates the Tombolo configuration"
      source_root File.expand_path("templates", __dir__)

      def create_initializer
        copy_file "initializer.rb", "config/initializers/tombolo.rb"
      end

      def create_prerender
        copy_file "prerender.ts", "app/javascript/prerender.ts"
      end
    end
  end
end
