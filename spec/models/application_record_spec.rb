# frozen_string_literal: true

require 'spec_helper'

describe ApplicationRecord do
  fixtures :all

  it 'sorts events by the country shown in the event list' do
    countries = Event.ransack(s: 'country_code asc').result.pluck(:country_code)

    expect(countries).to eq(Event.pluck(:country_code).sort)
  end

  it 'does not let searches filter by password hashes' do
    user_ids = User.ransack(encrypted_password_eq: 'not a stored hash').result.pluck(:id)

    expect(user_ids.sort).to eq(User.order(:id).pluck(:id))
  end
end
