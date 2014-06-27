require 'spec_helper'

describe TransitionEvent do
  fixtures :all


  it { should validate_presence_of :name }
  it { should validate_presence_of :machine_type }
  it { should validate_uniqueness_of :target_state_id }

  describe "#validates_machine_type" do
    before(:each) do
      @t_event = TransitionEvent.new
      @t_event.name="transition_event_one"
      @t_event.machine_type="request"
      #@t_event.save
    end

    it "should be valid if source states,target state and transition event belong to same machine" do
      
      @t_event.source_states<<[states(:state_one_request),states(:state_two_request)]
      @t_event.target_state=states(:target_state_for_request)
      @t_event.valid?
      @t_event.errors[:name].should_not include "is an invalid transition (mismatching machine_type)"

    end

    it "should be invalid if source states and target state don't belong to same machine" do
      
      @t_event.source_states<<[states(:state_one_request),states(:state_two_request)]
      @t_event.target_state=states(:target_state_for_reimbursement)
      @t_event.valid?
      @t_event.errors[:name].should include "is an invalid transition (mismatching machine_type)"

    end


    it "should be invalid if source states and transition event don't belong to same machine" do
      
      @t_event.source_states<<[states(:state_one_reimbursement),states(:state_two_reimbursement)]
      @t_event.target_state=states(:target_state_for_request)
      @t_event.valid?
      @t_event.errors[:name].should include "is an invalid transition (mismatching machine_type)"

    end


    it "should be invalid if target state and transition event don't belong to same machine" do
      
      @t_event.source_states<<[states(:state_one_request),states(:state_two_request)]
      @t_event.target_state=states(:target_state_for_reimbursement)
      @t_event.valid?
      @t_event.errors[:name].should include "is an invalid transition (mismatching machine_type)"

    end


  end

  it "should verify with the current request workflow" do

    #submit transition : incomplete->submitted
    transition_events(:submit).source_states.should == [states(:incomplete)]
    transition_events(:submit).target_state.should == states(:submitted)

    #roll_back transition : submitted,approved -> incomplete
    transition_events(:roll_back).source_states.should == [states(:submitted),states(:approved)]
    transition_events(:roll_back).target_state.should == states(:incomplete)

    #approve transition : submitted -> approved
    transition_events(:approve).source_states.should == [states(:submitted)]
    transition_events(:approve).target_state.should == states(:approved)

    #accept transition : approved -> accepted
    transition_events(:accept).source_states.should == [states(:approved)]
    transition_events(:accept).target_state.should == states(:accepted)


  end


end
