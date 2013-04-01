require 'spec_helper'
#require 'ruby-debug'

feature "Requests", "" do
  fixtures :events, :users, :user_profiles

  scenario "Full request process" do
    sign_in_as_user(users(:luke))
    visit event_path(events(:dagobah_camp))
    click_link "Apply"

    # Request creation
    page.should have_content "New request"
    fill_in "request_description", :with => "I need to go because a ghost told me to do it"
    fill_in "request_expenses_attributes_0_subject", :with => "Gas"
    fill_in "request_expenses_attributes_0_description", :with => "Gas"
    fill_in "request_expenses_attributes_0_estimated_amount", :with => "100"
    fill_in "request_expenses_attributes_0_estimated_currency", :with => "EUR"
    click_link "add expense"
    within(:xpath, "//tr[@class='nested-fields'][last()]") do
      find('input[name$="[subject]"]').set "Droid rental"
      find('input[name$="[description]"]').set "R2D2"
      #find('input[name$="[estimated_amount]"]').set "50"
      #find('input[name$="[estimated_currency]"]').set "EUR"
    end
    click_button "Create request"
    page.should have_content "request was successfully created"

    # Failed submission
    click_link "submit"
    fill_in "notes", :with => "Believe me, this is important"
    click_button "submit"
    page.should have_content "Something went wrong. Unable to submit."

    # Correct the request
    click_link "Edit"
    page.should have_content "Edit request"
    fill_in "request_expenses_attributes_1_estimated_amount", :with => "50"
    fill_in "request_expenses_attributes_1_estimated_currency", :with => "EUR"
    click_button "Update request"
    page.should have_content "request was successfully updated"

    # Submit again
    click_link "submit"
    fill_in "notes", :with => "Believe me, this is important"
    click_button "submit"
    page.should have_content "Successfully submitted."

    # Log in as tspmember
    click_link "Log out"
    sign_in_as_user(users(:tspmember))
    visit requests_path
    find(:xpath, "//table[contains(@class,'requests')]//tbody/tr[last()]/td[1]//a").click
    page.should have_content "request"
    page.should have_content "R2D2"

    # Failed approval
    click_link "approve"
    fill_in "notes", :with => "Ok. It's approved"
    click_button "approve"
    page.should have_content "Something went wrong. Not approved."
  end
end
