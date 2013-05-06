require 'spec_helper'
#require 'ruby-debug'

feature "Visa letter", "" do
  fixtures :events, :users, :user_profiles, :requests, :request_expenses

  scenario "Applying to an event without visa option" do
    sign_in_as_user(users(:luke))
    visit request_path(requests(:luke_for_party))
    # request show
    page.should_not have_content "isa letter needed"
    click_link "Edit"
    # edit_request form
    page.should have_content "Edit request"
    page.should_not have_content "isa letter needed"
  end

  scenario "Applying to a visa enabled event" do
    sign_in_as_user(users(:wedge))
    visit event_path(events(:dagobah_camp))
    click_link "Apply"

    # new_request form
    page.should have_content "New request"
    page.should have_content "isa letter needed"
    click_button "Create request"
    # request show
    page.should have_content "request was successfully created"
    page.should have_content "isa letter needed"
  end
end
