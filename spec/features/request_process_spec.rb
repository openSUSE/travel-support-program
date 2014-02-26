require 'spec_helper'
#require 'ruby-debug'

feature "Requests", "" do
  fixtures :all

  scenario "Full request process" do
    sign_in_as_user(users(:luke))
    visit event_path(events(:dagobah_camp))
    click_link "Apply"

    # Request creation
    page.should have_content "New request"
    fill_in "request_description", :with => "I need to go because a ghost told me to do it"
    select "Gas", :from => "request_expenses_attributes_0_subject"
    fill_in "request_expenses_attributes_0_description", :with => "Gas"
    fill_in "request_expenses_attributes_0_estimated_amount", :with => "100"
    select "EUR", :from => "request_expenses_attributes_0_estimated_currency"
    click_link "add expense"
    within(:xpath, "//tr[@class='nested-fields'][last()]") do
      find('select[name$="[subject]"]').set "Droid rental"
      find('input[name$="[description]"]').set "R2D2"
      #find('input[name$="[estimated_amount]"]').set "50"
      #find('input[name$="[estimated_currency]"]').set "EUR"
    end
    click_button "Create request"
    page.should have_content "request was successfully created"
    page.should have_content "request must be explicitly submitted."
    @request = Request.order(:created_at).last

    # Testing audits, just in case
    @request.audits.last.user.should == users(:luke)
    @request.expenses.first.audits.last.user.should == users(:luke)
    @request.expenses.last.audits.last.owner.should == @request

    # Failed submission
    click_link "Action"
    click_link "submit"
    fill_in "notes", :with => "I've not fulfilled the droid amount"
    click_button "submit"
    page.should have_content "Something went wrong. Unable to submit."

    # Correct the request
    close_modal_dialog
    click_link "Edit"
    page.should have_content "Edit request"
    fill_in "request_expenses_attributes_1_estimated_amount", :with => "50"
    select "EUR", :from => "request_expenses_attributes_1_estimated_currency"
    click_button "Update request"
    page.should have_content "request was successfully updated"

    # Submit again
    click_link "Action"
    click_link "submit"
    fill_in "notes", :with => "Ok, now all the information is there."
    click_button "submit"
    page.should have_content "Successfully submitted."
    page.should have_content "From incomplete to submitted"
    page.should have_content "waiting for approval"

    # Log in as tspmember
    click_link "Log out"
    find_request_as(users(:tspmember), @request)

    # Failed approval
    click_link "Action"
    click_link "approve"
    fill_in "notes", :with => "Trying to approve with no amount"
    click_button "approve"
    page.should have_content "Something went wrong. Not approved."

    # Fulfill approval information
    close_modal_dialog
    click_link "Edit"
    page.should have_content "Edit request"
    fill_in "request_expenses_attributes_0_approved_amount", :with => "60"
    select "EUR", :from => "request_expenses_attributes_0_approved_currency"
    fill_in "request_expenses_attributes_1_approved_amount", :with => "0"
    select "EUR", :from => "request_expenses_attributes_1_approved_currency"
    click_button "Update request"
    page.should have_content "request was successfully updated"

    # Approve again
    click_link "Action"
    click_link "approve"
    fill_in "notes", :with => "The Alliance do not pay droids"
    click_button "approve"
    page.should have_content "Successfully approved"
    page.should have_content "From submitted to approved"
    page.should have_content "requester has to accept the conditions"

    # Log in as requester
    click_link "Log out"
    find_request_as(users(:luke), @request)

    # Try to update
    page.should_not have_content "Edit"
    visit edit_request_path(@request)
    page.status_code.should == 403

    # Not possible, so roll back
    visit request_path(@request)
    click_link "Action"
    click_link "roll back"
    fill_in "notes", :with => "No way."
    click_button "roll back"
    page.should have_content "Successfully rolled back."
    page.should have_content "From approved to incomplete"
    page.should have_content "under modification"

    # And now edit
    click_link "Edit"
    page.should have_content "Edit request"
    fill_in "request_expenses_attributes_1_estimated_amount", :with => "35"
    click_button "Update request"
    page.should have_content "request was successfully updated"

    # And submit again
    click_link "Action"
    click_link "submit"
    fill_in "notes", :with => "I have negotiated a lower fare for R2D2 rental"
    click_button "submit"
    page.should have_content "Successfully submitted."
    page.should have_content "From incomplete to submitted"

    # Log in as tspmember
    click_link "Log out"
    find_request_as(users(:tspmember), @request)

    # Approval
    click_link "Action"
    click_link "approve"
    fill_in "notes", :with => "We do not pay droids anyway, not a matter of price."
    click_button "approve"
    page.should have_content "Successfully approved"
    page.should have_content "From submitted to approved"
    page.should have_content "ready for final requester's acceptance"

    # Log in as requester
    click_link "Log out"
    find_request_as(users(:luke), @request)

    # And finally accept
    click_link "Action"
    click_link "accept"
    fill_in "notes", :with => "Ok, just give the gas, then. But don't expect me to clean the droid properly... and we are going to a swamp."
    click_button "accept"
    page.should have_content "Acceptance processed"
    page.should have_content "From approved to accepted"
    page.should have_content "reimbursement process has started or can be started"
  end
end
