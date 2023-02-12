# frozen_string_literal: true

require "ipaddr"
require "logger"

require_relative "rack_do_app_platform_safelist/version"

# Rack middleware for digital ocean app platform that will block any ip address that is not saflisted using the
# ALLOWED_IPS enviroment variable by default.
#
#  Eg:
#   ALLOWED_IPS = "8.8.8.8,8.8.4.4,1.2.3.0/24"
class RackDoAppPlatformSafelist
  attr_reader :allowed_ips

  # @param logger [#info] the logger to use for messages. If nil it will use the value set in "rack.logger" if present
  #   or create a new logger instance.
  # @param env_key [#to_s] the environment variable to use to get the safelisted ips.
  def initialize(app, logger: nil, env_key: "ALLOWED_IPS")
    @app = app
    @logger = logger
    @allowed_ips = ENV.fetch(env_key.to_s, "").split(",").map(&:strip).uniq.map { |ip| IPAddr.new(ip) }
  end

  def call(env)
    client_ip = extract_client_ip(env)
    return @app.call(env) if safelisted_ip?(client_ip)

    logger(env).info(error_message(client_ip))
    [403, { "content-type" => "text/plain" }, ["Forbidden\n"]]
  end

  private

  def safelisted_ip?(client_ip)
    return false if client_ip.nil?

    IPAddr.new(client_ip).then { |ip| allowed_ips.any? { |allowed_ip| allowed_ip.include?(ip) } }
  end

  def extract_client_ip(env)
    # DigitalOcean's load balancer appends the client ip and the load balancer's ip to the X-Forwarded-For header so
    # since we know there will always be one load balancer infront of your application on App Platform we can split the
    # string on commas and the client ip will always be the second to last item in the array.
    env["HTTP_X_FORWARDED_FOR"].to_s.split(",")[-2]
  end

  def error_message(client_ip)
    message = client_ip.nil? ? "Could not determine client ip address" : "IP address #{client_ip} is not safelisted"

    "Blocking request - #{message}"
  end

  def logger(env)
    if @logger
      @logger
    elsif env["rack.logger"]
      env["rack.logger"]
    else
      ::Logger.new(env["rack.errors"])
    end

    # return @logger if @logger
    # return env["rack.logger"] if env["rack.logger"]

    # ::Logger.new(env["rack.errors"])
  end
end
