# knot-devise-jwt-helper

JWT authentication helper for [Devise](https://github.com/heartcombo/devise), providing token generation, validation, and refresh utilities for Rails APIs.

## Installation

Add to your `Gemfile`:

```ruby
gem 'knot-devise-jwt-helper', '~> 1.0'
```

Or install directly:

```sh
gem install knot-devise-jwt-helper
```

## Setup

```ruby
# config/initializers/devise_jwt.rb
Devise::JwtHelper.configure do |config|
  config.secret_key    = ENV['JWT_SECRET_KEY']
  config.expiration    = 24.hours
  config.algorithm     = 'HS256'
  config.issuer        = 'myapp.example.com'
  config.refresh_ttl   = 7.days
end
```

## Usage

### Generating a JWT token for a user

```ruby
class Api::V1::SessionsController < ApplicationController
  def create
    user = User.find_by(email: params[:email])

    if user&.valid_password?(params[:password])
      token = Devise::JwtHelper::Token.generate(user)
      render json: { token: token, expires_in: 24 * 3600 }, status: :ok
    else
      render json: { error: 'Invalid credentials' }, status: :unauthorized
    end
  end
end
```

### Validating a token in a before action

```ruby
class ApplicationController < ActionController::API
  before_action :authenticate_user_from_token!

  private

  def authenticate_user_from_token!
    header = request.headers['Authorization']
    token  = header&.split(' ')&.last

    payload = Devise::JwtHelper::Token.decode(token)
    @current_user = User.find(payload['sub'])
  rescue Devise::JwtHelper::Errors::ExpiredToken
    render json: { error: 'Token expired' }, status: :unauthorized
  rescue Devise::JwtHelper::Errors::InvalidToken
    render json: { error: 'Invalid token' }, status: :unauthorized
  end
end
```

### Refreshing a token

```ruby
class Api::V1::TokensController < ApplicationController
  def refresh
    new_token = Devise::JwtHelper::Token.refresh(current_user, params[:refresh_token])
    render json: { token: new_token }
  rescue Devise::JwtHelper::Errors::RefreshTokenExpired
    render json: { error: 'Refresh token expired, please log in again' }, status: :unauthorized
  end
end
```

### Revoking tokens (blocklist)

```ruby
# Add to your User model
class User < ApplicationRecord
  include Devise::JwtHelper::Revocable

  # Stores revoked JTIs in the database
  has_many :revoked_tokens, class_name: 'Devise::JwtHelper::RevokedToken'
end

# Revoke on sign-out
Devise::JwtHelper::Token.revoke(current_user, jti: payload['jti'])
```

## Requirements

- Ruby >= 2.7.0
- Rails >= 6.0
- Devise >= 4.8

## License

MIT License. See [LICENSE](LICENSE) for details.
