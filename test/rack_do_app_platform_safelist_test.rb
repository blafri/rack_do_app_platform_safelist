# frozen_string_literal: true

require "test_helper"

ENV["ALLOWED_IPS"] = "8.8.8.8, 1.1.1.0/24"
ENV["SAFELISTED_IPS"] = "8.8.4.4"

class RackDoAppPlatformSafelistTest < Minitest::Test
  include Rack::Test::Methods

  class TestApp
    def call(_env)
      [200, { "Content-Type" => "text/plain" }, ["Success"]]
    end
  end

  def app
    send(@rack_app || :default_rack_app)
  end

  def test_that_it_has_a_version_number
    refute_nil ::RackDoAppPlatformSafelist::VERSION
  end

  def test_safelisted_ips_are_not_blocked
    header "X-Forwarded-for", "8.8.8.8,10.0.0.1"
    get "/"

    assert_same(200, last_response.status)
  end

  def test_safelisted_ip_ranges_are_not_blocked
    header "X-Forwarded-for", "1.1.1.11,10.0.0.1"
    get "/"

    assert_same(200, last_response.status)
  end

  def test_non_safelisted_ips_are_blocked
    header "X-Forwarded-for", "8.8.4.4,10.0.0.1"
    get "/"

    assert_same(403, last_response.status)
  end

  def test_non_safelisted_ips_are_logged
    @logger = Minitest::Mock.new
    @logger.expect(:info, true, ["Blocking request - IP address 8.8.4.4 is not safelisted"])
    header "X-Forwarded-for", "8.8.4.4,10.0.0.1"
    get "/"

    assert(@logger.verify)
  end

  def test_log_is_created_if_client_ip_can_not_be_determiend
    @logger = Minitest::Mock.new
    @logger.expect(:info, true, ["Blocking request - Could not determine client ip address"])
    header "X-Forwarded-for", "10.0.0.1"
    get "/"

    assert(@logger.verify)
  end

  def test_log_is_created_if_forwarded_for_header_is_not_prensent
    @logger = Minitest::Mock.new
    @logger.expect(:info, true, ["Blocking request - Could not determine client ip address"])
    get "/"

    assert(@logger.verify)
  end

  def test_you_can_pass_in_env_variable_to_use
    @rack_app = :rack_app_with_custom_env_variable
    header "X-Forwarded-for", "8.8.4.4,10.0.0.1"
    get "/"

    assert_same(200, last_response.status)
  end

  def test_rack_logger_is_used_if_present_in_env
    logger = Minitest::Mock.new
    logger.expect(:info, true, ["Blocking request - IP address 8.8.4.4 is not safelisted"])
    header "X-Forwarded-for", "8.8.4.4,10.0.0.1"
    get "/", nil, "rack.logger" => logger

    assert(logger.verify)
  end

  private

  def default_rack_app
    logger = @logger

    Rack::Builder.new do
      use RackDoAppPlatformSafelist, logger: logger
      run TestApp.new
    end
  end

  def rack_app_with_custom_env_variable
    logger = @logger

    Rack::Builder.new do
      use RackDoAppPlatformSafelist, logger: logger, env_key: "SAFELISTED_IPS"
      run TestApp.new
    end
  end
end
