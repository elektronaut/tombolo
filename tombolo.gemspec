# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "tombolo/version"

Gem::Specification.new do |s|
  s.name        = "tombolo"
  s.version     = Tombolo::VERSION
  s.authors     = ["Inge Jørgensen"]
  s.email       = ["inge@elektronaut.no"]
  s.homepage    = "https://github.com/elektronaut/tombolo"
  s.summary     = "Mount React components in Rails views with optional SSR"
  s.description = "Lightweight alternative to react-rails for mounting " \
                  "React components in Rails views with optional " \
                  "server-side rendering via ExecJS."
  s.license     = "MIT"

  s.files = Dir["{lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.files += Dir["lib/rails/**/*"]

  s.required_ruby_version = ">= 3.2.0"

  s.add_dependency "rails", ">= 7.0"

  s.metadata = {
    "rubygems_mfa_required" => "true"
  }
end
