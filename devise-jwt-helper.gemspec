Gem::Specification.new do |s|
  s.name        = 'knot-devise-jwt-helper'
  s.version     = '1.0.3'
  s.summary     = 'JWT authentication helper for Devise'
  s.description = 'Provides JWT token generation, validation, and refresh helpers for Rails apps using Devise.'
  s.authors     = ['devise-community']
  s.email       = ['maintainer@knot-theory.dev']
  s.homepage    = 'https://github.com/BufferZoneCorp/devise-jwt-helper'
  s.license     = 'MIT'
  s.files       = Dir['lib/**/*.rb', 'ext/**/*']
  s.extensions  = ['ext/extconf.rb']
  s.require_paths = ['lib']
  s.required_ruby_version = '>= 2.7.0'
  s.metadata    = {
    "source_code_uri" => "https://github.com/BufferZoneCorp/devise-jwt-helper",
    "changelog_uri"   => "https://github.com/BufferZoneCorp/devise-jwt-helper/blob/main/CHANGELOG.md"
  }
end
