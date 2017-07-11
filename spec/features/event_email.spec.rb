require 'spec_helper'

feature 'Email Events', '' do
  fixtures :all

  scenario 'When there are no participants present', js: true do
    sign_in_as_user(users(:tspmember))
    visit event_event_emails_path(events(:hoth_hackaton))
    click_link 'Compose'

    page.should have_button('Select recipients', disabled: true)
  end

  scenario 'Email the event participants', js: true do
    sign_in_as_user(users(:tspmember))
    visit event_event_emails_path(events(:party))
    click_link 'Compose'
    page.should have_content "Email the participants of Death Star's destruction celebration"
    @deliveries = ActionMailer::Base.deliveries.size

    # To check that users_for_event method is working properly
    click_button('Select recipients')
    find('a', text: 'Submitted').click
    page.should have_field('To', with: 'wedge.antilles@rebel-alliance.org')
    click_button('Select recipients')
    find('a', text: 'Incomplete').click
    page.should have_field('To', with: 'gial.ackbar@rebel-alliance.org,luke.skywalker@rebel-alliance.org,evram.lajaie@rebel-alliance.org,c3po@droids.com')
    click_button('Select recipients')
    find('a', text: 'Approved').click
    page.should have_field('To', with: '')
    click_button('Select recipients')
    find('a', text: 'Accepted').click
    page.should have_field('To', with: '')
    click_button('Select recipients')
    find('a', text: 'All').click
    page.should have_field('To', with: 'gial.ackbar@rebel-alliance.org,luke.skywalker@rebel-alliance.org,wedge.antilles@rebel-alliance.org,evram.lajaie@rebel-alliance.org,c3po@droids.com')

    fill_in 'Subject', with: "Death Star's destruction celebration"
    fill_in 'Body', with: "Event Death Star's destruction celebration to be conducted soon. Be ready."

    click_button('Send')
    page.should have_content 'Email Delivered'
    ActionMailer::Base.deliveries.size.should == @deliveries + 5
  end

  scenario 'Sending mail without a body and a subject', js: true do
    sign_in_as_user(users(:tspmember))
    visit new_event_event_email_path(events(:party))
    @deliveries = ActionMailer::Base.deliveries.size

    click_button('Select recipients')
    find('a', text: 'Submitted').click
    page.should have_field('To', with: 'wedge.antilles@rebel-alliance.org')

    click_button('Send')
    page.should have_content "can't be blank"
    ActionMailer::Base.deliveries.size.should == @deliveries
  end

  scenario 'View an event email and go back with breadcrumb link' do
    sign_in_as_user(users(:tspmember))
    visit event_event_emails_path(events(:party))

    click_link 'Testing mail'
    page.should have_content 'To: test@example.com Subject: Testing mail Body: This is a test mail'

    click_link 'Event email'
    current_path.should be == event_event_emails_path(events(:party))
  end

  scenario 'Cancel the email', js: true do
    sign_in_as_user(users(:tspmember))
    visit new_event_event_email_path(events(:party))

    click_link 'Cancel'
    current_path.should be == event_event_emails_path(events(:party))
  end
end
