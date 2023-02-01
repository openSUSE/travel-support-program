# frozen_string_literal: true

require 'spec_helper'

describe Event do
  fixtures :all

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :start_date }
  it { is_expected.to validate_presence_of :end_date }
  it { is_expected.to validate_presence_of :country_code }

  describe '#accepting_shipments?' do
    it 'does not accept shipments for past events' do
      events(:training).should_not be_accepting_shipments
    end

    it 'does not accept shipments without type' do
      events(:dagobah_camp).should_not be_accepting_shipments
    end

    it 'does not accept shipments for past events without type' do
      events(:yavin_hackaton).should_not be_accepting_shipments
    end

    it 'accepts shipments for future events with type' do
      events(:party).should be_accepting_shipments
    end
  end
end
