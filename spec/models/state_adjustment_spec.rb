# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

describe StateAdjustment do
  fixtures :all

  it { is_expected.to validate_presence_of :from }
  it { is_expected.to validate_presence_of :to }
  it { is_expected.to validate_presence_of :user }
  it { is_expected.to validate_presence_of :machine }

  context 'when creating an adjustment' do
    # Incomplete request
    let(:request) { requests(:luke_for_party) }
    let!(:updated_at) { request.updated_at }
    let!(:state_updated_at) { request.state_updated_at }
    let(:user) { users(:supervisor) }
    let(:adjustment) { described_class.new }

    before do
      adjustment.user = user
      adjustment.machine = request
    end

    describe 'with valid state' do
      before do
        adjustment.to = 'submitted'
        sleep 2 # To ensure that we can compare timestamps
        adjustment.save
        request.reload
      end

      it 'is saved' do
        adjustment.should be_valid
        adjustment.should_not be_new_record
      end

      it 'changes the machine state' do
        request.state.should == 'submitted'
      end

      it 'changes both updated_at attributes' do
        request.updated_at.should > updated_at
        request.state_updated_at.should_not == state_updated_at
      end
    end

    describe 'with not valid state' do
      before do
        # It's already in incomplete state
        adjustment.to = 'incomplete'
        adjustment.save
        request.reload
      end

      it 'is not saved' do
        adjustment.should_not be_valid
        adjustment.should be_new_record
      end

      it 'does not update the machine' do
        request.updated_at.should == updated_at
        request.state_updated_at.should == state_updated_at
      end
    end
  end
end
