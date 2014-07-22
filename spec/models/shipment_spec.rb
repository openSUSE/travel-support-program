require 'spec_helper'
#require 'ruby-debug'

describe Shipment do
  fixtures :all

  describe "#shipment_type" do
    it "should be delegated to the event" do
      requests(:wedge_customes_for_party).shipment_type.should == "Wookiee customes box"
    end
  end

  describe "#state_updated_at" do
    before(:each) do
      @shipment = Shipment.new
      @shipment.user = users(:wedge)
      @shipment.event = events(:training)
      @shipment.save
    end

    it "should be nil for new events" do
      @shipment.state.should == 'incomplete'
      @shipment.state_updated_at.should be_nil
    end

    it "should be updated for on state changes" do
      transition(@shipment, :request, users(:wedge)) rescue nil
      @shipment.reload.state.should == "requested"
      @shipment.reload.state_updated_at.should_not be_nil
    end
  end

  context "during initial request" do
    before(:each) do
      @deliveries = ActionMailer::Base.deliveries.size
      @shipment = requests(:luke_customes_for_party)
      @audits = @shipment.audits
      transition(@shipment, :request, users(:luke))
    end

    it "should change the state" do
      @shipment.reload.state.should == "requested"
    end

    it "should notify requester and material manager" do
      ActionMailer::Base.deliveries.size.should == @deliveries + 2
    end

    it "should audit the change" do
      @shipment.audits.size == @audits.size + 1
    end

    it "should create an state transition" do
      trans = @shipment.transitions.last
      trans.from.should == "incomplete"
      trans.to.should == "requested"
      trans.state_event.should == "request"
    end

    it "should allow material managers to roll back" do
      transition(@shipment, :roll_back, users(:material))
      @shipment.state.should == "incomplete"
      trans = @shipment.transitions.last
      trans.from.should == "requested"
      trans.to.should == "incomplete"
      trans.state_event.should == "roll_back"
    end

    it "should allow material managers to approve" do
      transition(@shipment, :approve, users(:material))
      @shipment.reload.state.should == "approved"
      trans = @shipment.transitions.newest_first.reload.first
      trans.from.should == "requested"
      trans.to.should == "approved"
      trans.state_event.should == "approve"
    end
  end
end
