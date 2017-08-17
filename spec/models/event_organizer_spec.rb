require 'spec_helper'

describe EventOrganizer do
  fixtures :all

  it { should belong_to(:user) }
  it { should belong_to(:event) }

  it { should validate_presence_of :user_email }
  it { should validate_presence_of(:user_id).with_message('No such user exist') }
  it { should validate_presence_of :event_id }
  it { should validate_uniqueness_of(:user_id).scoped_to(:event_id).with_message('Already an event organizer for this event') }

  it 'nickname and email of the user' do
    expect(EventOrganizer.autocomplete_users('john')).to eq [['johnsnow', 'john.skywalker@rebel-alliance.org']]
    expect(EventOrganizer.autocomplete_users('co')).to eq [['C3PO', 'c3po@droids.com'], ['DD-19.A1', 'dd-19.a1@droids.com'], ['commanderlajaier', 'evram.lajaie@rebel-alliance.org']]
  end
end
