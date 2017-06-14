require 'spec_helper'
#require 'ruby-debug'

feature "Events", "" do
  fixtures :all

  scenario "Create event as requester", :js => true do
    sign_in_as_user(users(:luke))
    visit events_path
    confirm_msg = accept_confirm do
      click_link "New"
    end
    confirm_msg.should include "ake sure that the event is not currently included in the list"
    
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
    accept_confirm do
      click_link "New"
    end
    
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

  scenario "When a user is not logged in" do
    visit events_path 
    click_link "Death Star's destruction celebration"
    page.should_not have_link('Email') 
  end

  scenario "User logged in is not a tsp member" do
    sign_in_as_user(users(:luke))
    visit events_path 
    click_link "Death Star's destruction celebration"
    page.should_not have_link('Email') 
  end

  scenario "Email the event participants", :js => true do
    sign_in_as_user(users(:tspmember))
    visit events_path 
    click_link "Death Star's destruction celebration"
    
    click_link "Email"
    page.should have_content "Email the participants of Death Star's destruction celebration"
    
    # To check that users_for_event method is working properly
    click_button("Select recipients")
    find('a', :text => "All").click
    page.should have_field('To', with: 'gial.ackbar@rebel-alliance.org,luke.skywalker@rebel-alliance.org,wedge.antilles@rebel-alliance.org,evram.lajaie@rebel-alliance.org,c3po@droids.com')
    click_button("Select recipients")
    find('a', :text => "Submitted").click
    page.should have_field('To', with: 'wedge.antilles@rebel-alliance.org')
    click_button("Select recipients")
    find('a', :text => "Incomplete").click
    page.should have_field('To', with: 'gial.ackbar@rebel-alliance.org,luke.skywalker@rebel-alliance.org,evram.lajaie@rebel-alliance.org,c3po@droids.com')
    click_button("Select recipients")
    find('a', :text => "Approved").click
    page.should have_field('To', with: '')
    click_button("Select recipients")
    find('a', :text => "Accepted").click
    page.should have_field('To', with: '')

    click_link "Cancel"
    current_path.should == event_path(events(:party))
  end
end
