require 'spec_helper'

describe TransitionEvent do
  fixtures :all


  it { should validate_presence_of :name }
  it { should validate_presence_of :machine_type }
  #it { should validate_uniqueness_of :target_state_id }

  describe "#valid_transition?" do
    before(:each) do
      @t_event = TransitionEvent.new
      @t_event.name="transition_event_one"
      @t_event.machine_type="request"
      @t_event.save
    end

  	it "should be true if source states,target state and transition event belong to same machine" do
	  	
	  	@t_event.source_states<<[states(:incomplete_one_request),states(:incomplete_two_request)]
	  	@t_event.target_state=states(:submitted_for_request)
	  	@t_event.valid_transition?.should be_true

  	end

    it "should be false if source states and target state don't belong to same machine" do
      
      @t_event.source_states<<[states(:incomplete_one_request),states(:incomplete_two_request)]
      @t_event.target_state=states(:submitted_for_reimbursement)
      @t_event.valid_transition?.should be_false

    end

    it "should be false if source states and transition event don't belong to same machine" do
      
      @t_event.source_states<<[states(:incomplete_one_reimbursement),states(:incomplete_two_reimbursement)]
      @t_event.target_state=states(:submitted_for_request)
      @t_event.valid_transition?.should be_false

    end

    it "should be false if target state and transition event don't belong to same machine" do
      
      @t_event.source_states<<[states(:incomplete_one_request),states(:incomplete_two_request)]
      @t_event.target_state=states(:submitted_for_reimbursement)
      @t_event.valid_transition?.should be_false

    end

  end

end
