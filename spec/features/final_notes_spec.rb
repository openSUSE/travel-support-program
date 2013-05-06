require 'spec_helper'
require 'ruby-debug'

feature "Final notes", "" do
  fixtures :events, :users, :user_profiles, :requests, :request_expenses

  scenario "Not finished request" do
    sign_in_as_user(users(:luke))
    visit request_path(requests(:luke_for_party))
    find("h1").should have_content "request"
    page.should_not have_content "final note"
  end

  scenario "Empty note" do
    sign_in_as_user(users(:wedge))
    visit request_path(requests(:wedge_for_yavin))

    # Empty note
    click_link "Add final note"
    click_button "Create Final note"
    page.should have_content "Some error prevented the note to be added"
  end

  scenario "Add note" do
    sign_in_as_user(users(:wedge))
    visit request_path(requests(:wedge_for_yavin))
    find("h1").should have_content "request"

    click_link "Add final note"
    page.should have_xpath("//div[@id='new_final_note']")
    fill_in "final_note_body", :with => "Luke always get all the money. That's unfair."
    click_button "Create Final note"

    current_path.should == request_path(requests(:wedge_for_yavin))
    find("h1").should have_content "request"
    page.should_not have_xpath("//div[@id='new_final_note']")
    page.should have_content "Final note added"
    page.should have_content "final notes"
    page.should have_content "Luke always get all the money. That's unfair."
  end
end
