# frozen_string_literal: true

require "minitest/autorun"
require "minitest/mock"
require "active_support"
require "active_support/core_ext/object/json"
require "active_support/testing/assertions"
require "action_view"
require "tombolo"

module Minitest
  class Test
    include ActiveSupport::Testing::Assertions
  end
end
