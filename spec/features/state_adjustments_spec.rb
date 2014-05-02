require 'spec_helper'
# require 'ruby-debug'

feature "State adjustments", "" do
  fixtures :all

  scenario "Adjust a request", :js => true do
    find_request_as users(:supervisor), requests(:luke_for_party)
    click_link "Action"
    click_link "Adjust state"
    select "canceled", :from => :state_adjustment_to
    fill_in "notes", :with => "I know I could use the cancel button, but..."
    click_button "Create state adjustment"

    page.should have_content "The state has been changed"
    within(".request_state") do
      page.should have_content "canceled"
    end
  end

  scenario "Invalid adjustment", :js => true do
    find_reimbursement_as users(:supervisor), reimbursements(:wedge_for_training_reim)
    click_link "Action"
    click_link "Adjust state"
    select "incomplete", :from => :state_adjustment_to
    fill_in "notes", :with => "Quite stupid, in fact."
    click_button "Create state adjustment"

    page.should have_content("already the current state")
    # The dialog is open again
    page.should have_css(".modal", :visible => true)
  end
end
