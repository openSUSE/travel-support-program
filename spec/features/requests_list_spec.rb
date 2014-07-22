require 'spec_helper'
#require 'ruby-debug'

feature "Requests list", "" do
  fixtures :all

  scenario "with pending reimbursement" do
    sign_in_as_user(users(:luke))
    visit travel_sponsorships_path
    find("#request-#{requests(:luke_for_party).id} .reimbursement").should have_content "-"
    find("#request-#{requests(:luke_for_yavin).id} .reimbursement").should have_link "Create"
    # Click on the "create" button
    find("#request-#{requests(:luke_for_yavin).id} .reimbursement a").click
    page.should have_content "reimbursement was successfully created"
    # And go back to the list
    visit travel_sponsorships_path
    find("#request-#{requests(:luke_for_yavin).id} .reimbursement").should have_link requests(:luke_for_yavin).reimbursement.label
  end
end
