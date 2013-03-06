# encoding: utf-8
#
# Helpers for testing the application
#

module CommonHelpers

  #
  # User authentication
  #
  # Visits the login form and login with the password 'password'
  # unless another one is passed as an option
  #
  # @param [String] text  User to authenticate.
  # @param [Hash]   opts  +password+: password used for authentication.
  def sign_in_as_user(user, opts = {})
    options = { :context => "#new_user", :path => new_user_session_path, :password => 'password' }
    options.merge!(opts)
    visit options[:path] if options[:path]
    within(options[:context]) do
      fill_in "Email", :with => user.email
      fill_in "Password", :with => options[:password]
      click_button "Sign in"
    end
  end

end
