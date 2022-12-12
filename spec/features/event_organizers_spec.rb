# frozen_string_literal: true

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

    fill_in 'event_organizer_user_email', with: 'acala'
    find('#ui-id-2').click # Click the first item in the autocomplete dropdown
    page.should have_field('event_organizer_user_email', with: 'gial.ackbar@rebel-alliance.org')

    click_button 'Add'
    page.should have_content 'Event Organizer Added'
  end

  scenario 'When entered user does not exist', js: true do
    sign_in_as_user(users(:tspmember))
    visit new_event_event_organizer_path(events(:party))

    fill_in 'event_organizer_user_email', with: 'random_user'
    click_button 'Add'

    page.should have_content 'No such user exist'
  end
end
