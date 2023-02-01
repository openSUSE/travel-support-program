# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

describe Shipment do
  fixtures :all

  describe '#shipment_type' do
    it 'is delegated to the event' do
      requests(:wedge_costumes_for_party).shipment_type.should == 'Wookiee costumes box'
    end
  end

  describe '#state_updated_at' do
    let(:shipment) { described_class.new }

    before do
      shipment.user = users(:wedge)
      shipment.event = events(:training)
      shipment.save
    end

    it 'is nil for new events' do
      shipment.state.should == 'incomplete'
      shipment.state_updated_at.should be_nil
    end

    it 'is updated on state changes' do
      begin
        transition(shipment, :submit, users(:wedge))
      rescue
        nil
      end
      shipment.reload.state.should == 'submitted'
      shipment.reload.state_updated_at.should_not be_nil
    end
  end

  context 'when initially requested' do
    let!(:deliveries) { ActionMailer::Base.deliveries.size }
    let(:shipment) { requests(:luke_costumes_for_party) }
    let(:audits) { shipment.audits }

    before do
      transition(shipment, :submit, users(:luke))
    end

    it 'changes the state' do
      shipment.reload.state.should == 'submitted'
    end

    it 'notifies requester and material manager' do
      ActionMailer::Base.deliveries.size.should == deliveries + 2
    end

    it 'audits the change' do
      shipment.audits.size == audits.size + 1
    end

    it 'creates an state transition' do
      trans = shipment.transitions.last
      trans.from.should == 'incomplete'
      trans.to.should == 'submitted'
      trans.state_event.should == 'submit'
    end

    it 'allows material managers to roll back' do
      transition(shipment, :roll_back, users(:material))
      shipment.state.should == 'incomplete'
      trans = shipment.transitions.last
      trans.from.should == 'submitted'
      trans.to.should == 'incomplete'
      trans.state_event.should == 'roll_back'
    end

    it 'allows material managers to approve' do
      transition(shipment, :approve, users(:material))
      shipment.reload.state.should == 'approved'
      trans = shipment.transitions.newest_first.reload.first
      trans.from.should == 'submitted'
      trans.to.should == 'approved'
      trans.state_event.should == 'approve'
    end
  end
end
