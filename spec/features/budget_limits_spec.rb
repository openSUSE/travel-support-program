require 'spec_helper'
# require 'ruby-debug'

feature "Budget limits", "" do
  fixtures :all

  scenario "Trying to approve too much money", :js => true do
    sign_in_as_user(users(:tspmember))
    @request = requests(:wedge_for_party)
    visit travel_sponsorship_path(@request)
    click_link "Set amount"
    page.should have_content "Set approved amount"
    expense_id = @request.expenses.first.id
    fill_in "expenses_approval_amount_#{expense_id}", :with => "120"
    select "EUR", :from => "expenses_approval_currency_#{expense_id}"
    click_button "Update travel support request"
    page.should have_content "request was successfully updated"

    # Approval should fail
    click_link "Action"
    click_link "Approve"
    fill_in "notes", :with => "Not enough money, but let's try."
    click_button "approve"
    page.should have_content "Something went wrong. Not approved."
    page.should have_content "approved amount exceeds the budget"
  end

  scenario "Approving the right amount", :js => true do
    sign_in_as_user(users(:tspmember))
    @request = requests(:wedge_for_party)
    visit travel_sponsorship_path(@request)
    click_link "Set amount"
    page.should have_content "Set approved amount"
    expense_id = @request.expenses.first.id
    fill_in "expenses_approval_amount_#{expense_id}", :with => "110"
    select "EUR", :from => "expenses_approval_currency_#{expense_id}"
    click_button "Update travel support request"
    page.should have_content "request was successfully updated"

    # Approval should success
    click_link "Action"
    click_link "Approve"
    fill_in "notes", :with => "Not enough money, but let's try."
    click_button "approve"
    page.should have_content "Successfully approved"
    page.should have_content "from submitted to approved"
  end

  scenario "Choosing the currency", :js => true do
    sign_in_as_user(users(:tspmember))
    @request = requests(:wedge_for_party)
    visit travel_sponsorship_path(@request)
    click_link "Set amount"
    expense_id = @request.expenses.first.id
    page.should have_select "expenses_approval_currency_#{expense_id}", :with_options => %w(EUR)
    page.should_not have_select "expenses_approval_currency_#{expense_id}", :with_options => %w(USD)
  end
end
