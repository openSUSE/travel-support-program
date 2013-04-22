require 'devise'

require 'devise/strategies/opensuse_authenticatable'

module Devise
  # Configuration params
  @@opensuse_test_mode = false
  @@opensuse_test_username = nil
  @@opensuse_test_email = nil

  mattr_accessor :opensuse_test_mode, :opensuse_test_username, :opensuse_test_email
end

Devise.add_module :opensuse_authenticatable,
  :strategy => true,
  :controller => :sessions,
  :route => :session
