# frozen_string_literal: true

require "tombolo/view_helper"

module Tombolo
  class Railtie < Rails::Railtie
    initializer "tombolo.view_helper" do
      ActiveSupport.on_load(:action_view) do
        include Tombolo::ViewHelper
      end
    end
  end
end
