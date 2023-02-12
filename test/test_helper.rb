# frozen_string_literal: true

require "simplecov"
SimpleCov.start

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rack_do_app_platform_safelist"
require "minitest/autorun"
require "rack"
require "rack/test"
require "debug"
