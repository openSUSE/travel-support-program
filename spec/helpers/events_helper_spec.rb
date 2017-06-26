require 'spec_helper'

describe EventsHelper, type: :helper do
  fixtures :all
  before :each do
    @event = events(:party)
  end

  describe '#users_for_event' do
    it 'returns email of all the participants of the event' do
      expect(users_for_event('all')).to eq(['gial.ackbar@rebel-alliance.org', 'luke.skywalker@rebel-alliance.org', 'wedge.antilles@rebel-alliance.org', 'evram.lajaie@rebel-alliance.org',
                                            'c3po@droids.com'])
    end
    it 'returns emails of participants with their request in submitted state' do
      expect(users_for_event('submitted')).to eq(['wedge.antilles@rebel-alliance.org'])
    end
    it 'returns emails of participants with their request in incomplete state' do
      expect(users_for_event('incomplete')).to eq(['gial.ackbar@rebel-alliance.org', 'luke.skywalker@rebel-alliance.org', 'evram.lajaie@rebel-alliance.org', 'c3po@droids.com'])
    end
    it 'returns emails of participants with their request in canceled state' do
      expect(users_for_event('canceled')) .to eq([])
    end
    it 'returns emails of participants with their request in approved state' do
      expect(users_for_event('approved')) .to eq([])
    end
    it 'returns emails of participants with their request in accepted state' do
      expect(users_for_event('accepted')) .to eq([])
    end
  end
end
