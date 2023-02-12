# frozen_string_literal: true

require_relative "lib/rack_do_app_platform_safelist/version"

Gem::Specification.new do |spec|
  spec.name = "rack_do_app_platform_safelist"
  spec.version = RackDoAppPlatformSafelist::VERSION
  spec.authors = ["Blayne Farinha"]
  spec.email = ["blayne.farinha@gmail.com"]

  spec.summary = "Rack middleware for safelisting IP addresses in DigitalOcean's App Platform"
  spec.description = "Rack middleware for safelisting IP addresses using an environment variables in DigitalOcean's " \
                     "App Platform"
  spec.homepage = "https://github.com/blafri/rack_do_app_platform_safelist"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/blafri/rack_do_app_platform_safelist"
  spec.metadata["changelog_uri"] = "https://github.com/blafri/rack_do_app_platform_safelist/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
