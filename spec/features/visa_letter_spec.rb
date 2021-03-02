require 'spec_helper'
# require 'ruby-debug'

feature 'Visa letter', '' do
  fixtures :all

  scenario 'Applying to an event without visa option' do
    sign_in_as_user(users(:luke))
    visit travel_sponsorship_path(requests(:luke_for_party))
    # request show
    page.should_not have_content 'isa letter needed'
    click_link 'Edit'
    # edit_request form
    page.should have_content 'Edit travel support request'
    page.should_not have_content 'isa letter needed'
  end

  scenario 'Applying to a visa enabled event' do
    sign_in_as_user(users(:wedge))
    visit event_path(events(:dagobah_camp))
    click_link 'Travel support'

    # new_request form
    page.should have_content 'New travel support request'
    page.should have_content 'isa letter needed'
    click_button 'Create travel support request'
    # request show
    page.should have_content 'request was successfully created'
    page.should have_content 'isa letter needed'
  end
end
