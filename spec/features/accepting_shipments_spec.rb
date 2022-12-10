# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

feature 'accepting shipment?', '' do
  fixtures :all

  scenario 'Trying to apply to an event with accepting_shipments? == true' do
    sign_in_as_user(users(:wedge))
    visit event_path(events(:party))
    page.should have_link 'Merch. shipment'
  end

  scenario 'Trying to apply to an event with accepting_shipments? == false' do
    sign_in_as_user(users(:wedge))
    visit event_path(events(:training))
    page.should_not have_link 'Merch. shipment'
  end
end
