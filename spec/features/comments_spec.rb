require 'spec_helper'
# require 'ruby-debug'

feature 'Comments', '' do
  fixtures :all

  scenario 'Empty comment', js: true do
    sign_in_as_user(users(:wedge))
    visit travel_sponsorship_path(requests(:wedge_for_yavin))

    # Empty note
    click_link 'Add comment'
    click_button 'Create comment'
    page.should have_content 'Some error prevented the comment to be added'
  end

  scenario 'Add comment as requester', js: true do
    sign_in_as_user(users(:wedge))
    visit travel_sponsorship_path(requests(:wedge_for_yavin))
    find('h1').should have_content 'request'
    @deliveries = ActionMailer::Base.deliveries.size

    click_link 'Add comment'
    page.should have_xpath("//div[@id='new_comment']")
    page.should_not have_field 'private'
    page.should_not have_content TravelSponsorship.private_comment_hint
    fill_in 'comment_body', with: "Luke always get all the money. That's unfair."
    click_button 'Create comment'

    current_path.should == travel_sponsorship_path(requests(:wedge_for_yavin))
    find('h1').should have_content 'request'
    page.should_not have_xpath("//div[@id='new_comment']")
    page.should have_content 'Comment added'
    page.should have_content 'history'
    page.should have_content "Luke always get all the money. That's unfair."
    ActionMailer::Base.deliveries.size.should == @deliveries + 3
  end

  scenario 'Add private comment', js: true do
    sign_in_as_user(users(:tspmember))
    visit travel_sponsorship_path(requests(:wedge_for_yavin))
    find('h1').should have_content 'request'
    @deliveries = ActionMailer::Base.deliveries.size

    click_link 'Add comment'
    page.should have_xpath("//div[@id='new_comment']")
    page.should have_field 'private' # Is checked by default
    page.should have_content TravelSponsorship.private_comment_hint
    fill_in 'comment_body', with: "I don't like this guy, but don't tell him."
    click_button 'Create comment'

    current_path.should == travel_sponsorship_path(requests(:wedge_for_yavin))
    find('h1').should have_content 'request'
    page.should_not have_xpath("//div[@id='new_comment']")
    page.should have_content 'Comment added'
    page.should have_content 'history'
    page.should have_content 'private'
    page.should have_content "I don't like this guy"
    ActionMailer::Base.deliveries.size.should == @deliveries + 2

    # Check that it's not visible for the requester
    logout
    sign_in_as_user(users(:wedge))
    visit travel_sponsorship_path(requests(:wedge_for_yavin))
    page.should have_content 'history'
    page.should_not have_content "I don't like this guy"
  end
end
