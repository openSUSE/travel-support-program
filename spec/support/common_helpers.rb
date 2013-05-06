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
  # @param [User]  user  User to authenticate.
  # @param [Hash]  opts  +password+: password used for authentication.
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

  #
  # Find a give request through the index view
  #
  # Logs in as a user, goes to the list of requests and clicks on the given
  # request. At the moment of calling, no user should be already signed in.
  #
  # @param [User]    user     User to authenticate
  # @param [Request] request  Request to look for
  # @param [Hash]    opt      +password+: password used for authentication
  def find_request_as(user, request, opts = {})
    sign_in_as_user(user, opts)
    visit requests_path
    find(:xpath, "//table[contains(@class,'requests')]//tbody/tr[last()]/td[1]//a[text()='##{request.id}']").click
    page.should have_content "request"
    request.expenses.each do |e|
      page.should have_content e.subject
      page.should have_content e.description
    end
  end

  #
  # Creates a StateTransition for a request or a reimbursement
  #
  # @param [#state]  machine      Request or Reimbursement
  # @param [Symbol]  state_event  Event to trigger on the event machine
  # @param [User]    user         Obvious
  def transition(machine, state_event, user)
      submission = StateTransition.new(:state_event => state_event.to_s)
      submission.machine = machine
      submission.user = user
      submission.save!
  end

end
