require 'spec_helper'
# require 'ruby-debug'

feature "Only one active request", "" do
  fixtures :all

  scenario "Trying to create a new request" do
    sign_in_as_user(users(:luke))
    visit event_path(events(:party))
    click_link "Apply"

    # Redirect
    current_path.should == request_path(requests(:luke_for_party))
    page.should have_content "A request already exists for this event. Redirected"
  end
end
