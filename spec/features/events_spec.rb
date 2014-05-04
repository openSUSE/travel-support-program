require 'spec_helper'
#require 'ruby-debug'

feature "Events", "" do
  fixtures :all

  scenario "Create event as requester", :js => true do
    sign_in_as_user(users(:luke))
    visit events_path
    page.driver.accept_js_confirms!
    click_link "New"
    page.driver.confirm_messages.first.should include "ake sure that the event is not currently included in the list"
    
    # Protected attributes should not be displayed
    page.should_not have_field 'event[visa_letters]'
    page.should_not have_field 'validated'
    page.should_not have_field 'Budget'

    # Fill in the information
    fill_in 'name', :with => 'Battle of Endor'
    fill_in 'starts at', :with => '2112-12-11'
    fill_in 'ends at', :with => '2112-12-12'
    select "United States", :from => "country"
    
    click_button "Create event"
    page.should have_content "vent was successfully created"
    page.should_not have_content "validated"
  end

  scenario "Create event as tsp member", :js => true do
    sign_in_as_user(users(:tspmember))
    visit events_path
    page.driver.accept_js_confirms!
    click_link "New"
    
    # Fill in the information
    fill_in 'name', :with => 'Battle of Endor'
    fill_in 'starts at', :with => '2112-12-11'
    fill_in 'ends at', :with => '2112-12-12'
    select "United States", :from => "country"
    check 'validated'

    click_button "Create event"
    page.should have_content "vent was successfully created"
    within('.wrapper.event_visa_letters') do
      page.should have_content 'No'
    end
    within('.wrapper.event_validated') do
      page.should have_content 'Yes'
    end
    page.should have_content 'Budget'
  end
end
