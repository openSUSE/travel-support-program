require 'spec_helper'
# require 'ruby-debug'

describe Shipment do
  fixtures :all

  describe '#shipment_type' do
    it 'should be delegated to the event' do
      requests(:wedge_costumes_for_party).shipment_type.should == 'Wookiee costumes box'
    end
  end

  describe '#state_updated_at' do
    before(:each) do
      @shipment = Shipment.new
      @shipment.user = users(:wedge)
      @shipment.event = events(:training)
      @shipment.save
    end

    it 'should be nil for new events' do
      @shipment.state.should == 'incomplete'
      @shipment.state_updated_at.should be_nil
    end

    it 'should be updated on state changes' do
      begin
        transition(@shipment, :submit, users(:wedge))
      rescue
        nil
      end
      @shipment.reload.state.should == 'submitted'
      @shipment.reload.state_updated_at.should_not be_nil
    end
  end

  context 'during initial request' do
    before(:each) do
      @deliveries = ActionMailer::Base.deliveries.size
      @shipment = requests(:luke_costumes_for_party)
      @audits = @shipment.audits
      transition(@shipment, :submit, users(:luke))
    end

    it 'should change the state' do
      @shipment.reload.state.should == 'submitted'
    end

    it 'should notify requester and material manager' do
      ActionMailer::Base.deliveries.size.should == @deliveries + 2
    end

    it 'should audit the change' do
      @shipment.audits.size == @audits.size + 1
    end

    it 'should create an state transition' do
      trans = @shipment.transitions.last
      trans.from.should == 'incomplete'
      trans.to.should == 'submitted'
      trans.state_event.should == 'submit'
    end

    it 'should allow material managers to roll back' do
      transition(@shipment, :roll_back, users(:material))
      @shipment.state.should == 'incomplete'
      trans = @shipment.transitions.last
      trans.from.should == 'submitted'
      trans.to.should == 'incomplete'
      trans.state_event.should == 'roll_back'
    end

    it 'should allow material managers to approve' do
      transition(@shipment, :approve, users(:material))
      @shipment.reload.state.should == 'approved'
      trans = @shipment.transitions.newest_first.reload.first
      trans.from.should == 'submitted'
      trans.to.should == 'approved'
      trans.state_event.should == 'approve'
    end
  end
end
