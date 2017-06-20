require 'spec_helper'
# require 'ruby-debug'

feature 'Acceptance info', '' do
  fixtures :all

  let(:reimb) { reimbursements(:wedge_for_training_reim) }

  scenario 'is displayed when acceptance is required', js: true do
    find_reimbursement_as(users(:wedge), reimb)
    page.should have_link 'Attach signed document'
    page.should have_content 'An updated signed version of the reimbursement request is required'
    page.should_not have_content 'The requester will be able to update this document'
    page.should_not have_content 'A signed copy of the reimbursement could be explicitly requested'
  end

  scenario 'is displayed after submision without document', js: true do
    adjust_state(reimb, 'submitted')
    find_reimbursement_as(users(:wedge), reimb)
    page.should_not have_content 'An updated signed version of the reimbursement request is required'
    page.should_not have_content 'The requester will be able to update this document'
    page.should have_content 'A signed copy of the reimbursement could be explicitly requested'
  end

  scenario 'is displayed after submision with document', js: true do
    adjust_state(reimb, 'submitted')
    set_acceptance_file reimb
    reimb.save!
    find_reimbursement_as(users(:wedge), reimb)
    page.should_not have_content 'An updated signed version of the reimbursement request is required'
    page.should have_content 'The requester will be able to update this document'
    page.should_not have_content 'A signed copy of the reimbursement could be explicitly requested'
  end
end
