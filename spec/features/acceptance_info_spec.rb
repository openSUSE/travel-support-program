require 'spec_helper'
# require 'ruby-debug'

feature "Acceptance info", "" do
  fixtures :all

  let(:reimb) { reimbursements(:wedge_for_training_reim) }

  scenario "is not present by default" do
    find_reimbursement_as(users(:wedge), reimb)
    page.should_not have_content "An updated signed version of the reimbursement request is required"
    page.should_not have_content "You will be able to update this document"
  end

  scenario "is displayed when acceptance is required", :js => true do
    adjust_state(reimb, "approved")
    find_reimbursement_as(users(:wedge), reimb)
    page.should have_content "An updated signed version of the reimbursement request is required"
    page.should_not have_content "You will be able to update this document"
  end

  # Use rack_test to force everything to run in the same thread, so capybara
  # checks are aware of the changes in the database
  scenario "is displayed for probably outdated acceptance" do
    set_acceptance_file reimb
    reimb.save!
    find_reimbursement_as(users(:wedge), reimb)
    page.should_not have_content "An updated signed version of the reimbursement request is required"
    page.should have_content "You will be able to update this document"
  end
end
