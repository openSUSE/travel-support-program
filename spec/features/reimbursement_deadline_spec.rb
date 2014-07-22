require 'spec_helper'
#require 'ruby-debug'

feature "Reimbursement deadline", "" do
  fixtures :all

  scenario "Closing an event for reimbursements" do
    sign_in_as_user(users(:tspmember))
    visit event_path(events(:yavin_hackaton))
    click_link "Edit"
    fill_in "accepting reimbursements until", :with => 12.hours.ago.to_s
    click_button "Update event"
    page.should have_content "event was successfully updated"
    logout

    sign_in_as_user(users(:luke))
    visit travel_sponsorship_path(requests(:luke_for_yavin))
    page.should_not have_button "Ask for reimbursement"
    page.should have_content "event is not open"
  end
end
