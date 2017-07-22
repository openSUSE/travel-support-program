require 'spec_helper'

feature 'Email Events', '' do
  fixtures :all

  scenario 'When logged in as a tsp member' do
    sign_in_as_user(users(:tspmember))
    visit event_event_organizers_path(events(:party))

    page.should have_content "Event Organizers of Death Star's destruction celebration"
  end

  scenario 'When logged in as a requester' do
    sign_in_as_user(users(:luke))
    visit event_event_organizers_path(events(:party))

    page.should have_content 'You are not allowed to access this page'
  end

  scenario 'Adding an event organizer', js: true do
    sign_in_as_user(users(:tspmember))
    visit event_event_organizers_path(events(:party))

    click_link 'Add Event Organizer'
    page.should have_content "Add an event organizer for Death Star's destruction celebration"

    fill_in 'event_organizer_user_email', with: users(:wedge).email
    click_button 'Add'

    page.should have_content 'Event Organizer Added'
  end
end
