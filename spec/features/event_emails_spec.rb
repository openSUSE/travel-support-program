require 'spec_helper'

feature 'Email Events', '' do
  fixtures :all

  scenario 'When logged in as a requester' do
    sign_in_as_user(users(:wedge))

    visit event_event_emails_path(events(:party))
    page.should have_content 'You are not allowed to access this page'

    visit event_event_emails_path(events(:hoth_hackaton))
    page.should have_content 'You are not allowed to access this page'
  end

  scenario 'When logged in as an event organizer' do
    sign_in_as_user(users(:luke))

    visit event_event_emails_path(events(:party))
    page.should have_content "Event email Emails for Death Star's destruction celebration"

    visit event_event_emails_path(events(:hoth_hackaton))
    page.should have_content 'You are not allowed to access this page'
  end

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
    page.check('Accepted')
    page.should have_field('To', with: 'No recipients')

    page.check('Submitted')
    page.should have_field('To', with: 'wedge.antilles@rebel-alliance.org')

    page.uncheck('Submitted')
    page.check('Approved')
    page.should have_field('To', with: 'No recipients')

    page.check('Submitted')
    page.check('Incomplete')
    page.should have_field('To', with: 'gial.ackbar@rebel-alliance.org,luke.skywalker@rebel-alliance.org,evram.lajaie@rebel-alliance.org,'\
        'c3po@droids.com,wedge.antilles@rebel-alliance.org')

    page.check('All')
    page.should have_field('To', with: 'gial.ackbar@rebel-alliance.org,luke.skywalker@rebel-alliance.org,evram.lajaie@rebel-alliance.org,'\
        'c3po@droids.com,wedge.antilles@rebel-alliance.org')

    fill_in 'Subject', with: "Death Star's destruction celebration"
    fill_in 'event_email_body', with: "Event Death Star's destruction celebration to be conducted soon. Be ready."

    page.find('.btn-primary').trigger('click')
    page.should have_content 'Email Delivered'
    ActionMailer::Base.deliveries.size.should == @deliveries + 5
  end

  scenario 'Sending mail without a body and a subject', js: true do
    sign_in_as_user(users(:tspmember))
    visit new_event_event_email_path(events(:party))
    @deliveries = ActionMailer::Base.deliveries.size

    click_button('Select recipients')
    page.check('Submitted')
    page.should have_field('To', with: 'wedge.antilles@rebel-alliance.org')

    page.find('.btn-primary').trigger('click')
    page.should have_content "can't be blank"
    ActionMailer::Base.deliveries.size.should == @deliveries
  end

  scenario 'Viewing the markdown preview', js: true do
    sign_in_as_user(users(:tspmember))
    visit new_event_event_email_path(events(:party))

    fill_in 'event_email_body', with: "# Death Star's destruction celebration"
    click_link 'Preview'
    within(:xpath, '//*[@id="preview_screen"]') do
      page.should have_css('h1', text: "Death Star's destruction celebration")
    end
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
