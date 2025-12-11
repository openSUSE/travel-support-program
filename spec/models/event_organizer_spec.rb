# frozen_string_literal: true

require 'spec_helper'

describe EventOrganizer do
  fixtures :all

  it { is_expected.to belong_to(:user) }
  it { is_expected.to belong_to(:event) }

  it { is_expected.to validate_presence_of :user_email }
  it { is_expected.to validate_presence_of(:user_id).with_message('No such user exist') }
  it { is_expected.to validate_presence_of :event_id }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:event_id).with_message('Already an event organizer for this event') }

  it 'nickname of the user' do
    expect(described_class.autocomplete_users('john')).to eq [['johnsnow', 'john.skywalker@rebel-alliance.org']]
  end

  it 'email of the user' do
    expect(described_class.autocomplete_users('co')).to eq [['C3PO', 'c3po@droids.com'],
                                                            ['commanderlajaier', 'evram.lajaie@rebel-alliance.org'],
                                                            ['DD-19.A1', 'dd-19.a1@droids.com']]
  end
end
