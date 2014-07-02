require 'spec_helper'
#require 'ruby-debug'

feature "Request deadline", "" do
  fixtures :all

  scenario "Trying to apply to an open event" do
    sign_in_as_user(users(:wedge))
    visit event_path(events(:dagobah_camp))
    within('.page-header') do
      page.should have_link "Travel support"
    end
  end

  scenario "Trying to apply to an closed event" do
    sign_in_as_user(users(:wedge))
    visit event_path(events(:hoth_hackaton))
    within('.page-header') do
      page.should_not have_link "Travel support"
    end
  end

  scenario "Trying to apply to a past event" do
    sign_in_as_user(users(:wedge))
    visit event_path(events(:yavin_hackaton))
    within('.page-header') do
      page.should_not have_link "Travel support"
    end
  end
end
