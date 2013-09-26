require 'spec_helper'
#require 'ruby-debug'

feature "Budget limits", "" do
  fixtures :all

  scenario "Trying to approve with no budget" do
    sign_in_as_user(users(:tspmember))
    visit request_path(requests(:wedge_for_party))
    click_link "Edit"
    page.should have_content "Edit request"
    fill_in "request_expenses_attributes_0_approved_amount", :with => "60"
    select "USD", :from => "request_expenses_attributes_0_approved_currency"
    click_button "Update request"
    page.should have_content "request was successfully updated"

    # Approval should fail
    click_link "Action"
    click_link "approve"
    fill_in "notes", :with => "No USD budget, but let's try."
    click_button "approve"
    page.should have_content "Something went wrong. Not approved."
    page.should have_content "no budget defined"
  end

  scenario "Trying to approve too much money" do
    sign_in_as_user(users(:tspmember))
    visit request_path(requests(:wedge_for_party))
    click_link "Edit"
    page.should have_content "Edit request"
    fill_in "request_expenses_attributes_0_approved_amount", :with => "120"
    select "EUR", :from => "request_expenses_attributes_0_approved_currency"
    click_button "Update request"
    page.should have_content "request was successfully updated"

    # Approval should fail
    click_link "Action"
    click_link "approve"
    fill_in "notes", :with => "Not enough money, but let's try."
    click_button "approve"
    page.should have_content "Something went wrong. Not approved."
    page.should have_content "approved amount exceeds the budget"
  end

  scenario "Approving the right amount" do
    sign_in_as_user(users(:tspmember))
    visit request_path(requests(:wedge_for_party))
    click_link "Edit"
    page.should have_content "Edit request"
    fill_in "request_expenses_attributes_0_approved_amount", :with => "110"
    select "EUR", :from => "request_expenses_attributes_0_approved_currency"
    click_button "Update request"
    page.should have_content "request was successfully updated"

    # Approval should fail
    click_link "Action"
    click_link "approve"
    fill_in "notes", :with => "Not enough money, but let's try."
    click_button "approve"
    page.should have_content "Successfully approved"
    page.should have_content "From submitted to approved"
  end
end
