# Rack DigitalOcean AppPlatform Safelist

Simple rack middleware for ruby applications hosted on Digital Ocean app platform to block ip addresses that are not
safelisted via an environment variable.

Simply add an environment variable called ALLOWED_IPS that contains a comma seperated list of ips that are allowed to
access you application (you can use CIDR notation as well to safelist ips).

Example:

ALLOWED_IPS = "8.8.8.8, 8.8.4.4, 1.2.3.0/24"

## Getting started

### Installing

Add this line to your application's Gemfile:

```ruby
# In your Gemfile

gem "rack_do_app_platform_safelist"
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack_do_app_platform_safelist

### Plugging into the application

Then tell your ruby web application to use the middleware.

a) For __rails__ applications.

```ruby
# In config/initializers/rack_do_app_platform_safelist.rb

require "rack_do_app_platform_safelist"

Rails.application.config.middleware.insert_before(0, RackDoAppPlatformSafelist, logger: Rails.logger)
```

This will insert the middleware at the top of the middleware stack so it can block request before reaching any other
middleware in your application

b) For __rack__ applications:

```ruby
# In config.ru

require "rack_do_app_platform_safelist"

use RackDoAppPlatformSafelist
run App.new
```

If you want to use a different environment variable for the whitelisted IPs you can pass it as an argument

a) For __rails__ applications.

```ruby
# In config/initializers/rack_do_app_platform_safelist.rb

require "rack_do_app_platform_safelist"

Rails.application.config.middleware.insert_before(0, RackDoAppPlatformSafelist, logger: Rails.logger,
                                                                                env_key: "SAFELISTED_IPS")
```

b) For __rack__ applications:

```ruby
# In config.ru

require "rack_do_app_platform_safelist"

use RackDoAppPlatformSafelist, env_key: "SAFELISTED_IPS"
run App.new
```

The middleware will now look for the IP addresses to safelist in the SAFELISTED_IPS environment variable.
