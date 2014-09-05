require 'spec_helper'
# require 'ruby-debug'

feature "Only one active request", "" do
  fixtures :all

  scenario "Trying to create a new request" do
    sign_in_as_user(users(:luke))
    visit event_path(events(:party))
    click_link "Travel support"

    # Redirect
    current_path.should == travel_sponsorship_path(requests(:luke_for_party))
    page.should have_content "A request already exists for this event. Redirected"
  end
end
