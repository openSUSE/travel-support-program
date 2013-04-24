require 'devise/strategies/base'

class Devise::Strategies::OpensuseAuthenticatable < Devise::Strategies::Authenticatable

  def store?
    super && !mapping.to.skip_session_storage.include?(:opensuse_auth)
  end

  def valid?
    ::Devise.opensuse_test_mode || !request.env['HTTP_X_USERNAME'].blank?
  end

  def authenticate!
    if ::Devise.opensuse_test_mode
      proxy_user = ::Devise.opensuse_test_username
      proxy_email = ::Devise.opensuse_test_email
    else
      proxy_user = request.env['HTTP_X_USERNAME']
      proxy_email = request.env['HTTP_X_EMAIL']
    end
    if proxy_user
      resource = mapping.to.find_or_create_from_opensuse(proxy_user, proxy_email)
      resource ? success!(resource) : fail!
    else
      fail!
    end
  end
end

Warden::Strategies.add :opensuse_authenticatable, Devise::Strategies::OpensuseAuthenticatable
