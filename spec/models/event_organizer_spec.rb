require 'spec_helper'

describe EventOrganizer do
  fixtures :all

  it { should belong_to(:user) }
  it { should belong_to(:event) }

  it { should validate_presence_of :user_email }
  it { should validate_presence_of(:user_id).with_message('No such user exist') }
  it { should validate_presence_of :event_id }
  it { should validate_uniqueness_of(:user_id).scoped_to(:event_id).with_message('Already an event organizer for this event') }
end
