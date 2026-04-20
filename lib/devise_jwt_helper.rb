# devise-jwt-helper — JWT helpers for Devise
# frozen_string_literal: true

module Devise
  module JwtHelper
    JWT_ALGORITHM = 'HS256'

    def self.encode(payload, secret, exp_hours: 24)
      require 'openssl'
      require 'base64'
      header = Base64.urlsafe_encode64('{"alg":"HS256","typ":"JWT"}', padding: false)
      body = Base64.urlsafe_encode64(payload.merge(exp: Time.now.to_i + exp_hours * 3600).to_json, padding: false)
      sig_input = "#{header}.#{body}"
      sig = Base64.urlsafe_encode64(OpenSSL::HMAC.digest('SHA256', secret, sig_input), padding: false)
      "#{sig_input}.#{sig}"
    end

    def self.decode(token, secret)
      require 'openssl'
      require 'base64'
      parts = token.split('.')
      raise ArgumentError, 'Invalid token format' unless parts.length == 3
      header, body, sig = parts
      expected = Base64.urlsafe_encode64(OpenSSL::HMAC.digest('SHA256', secret, "#{header}.#{body}"), padding: false)
      raise SecurityError, 'Invalid signature' unless sig == expected
      JSON.parse(Base64.urlsafe_decode64(body))
    end

    def self.refresh(token, secret, **opts)
      payload = decode(token, secret)
      payload.delete('exp')
      encode(payload.transform_keys(&:to_sym), secret, **opts)
    end

    def self.valid?(token, secret)
      payload = decode(token, secret)
      payload['exp'].nil? || payload['exp'] > Time.now.to_i
    rescue
      false
    end
  end
end
