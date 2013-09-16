require 'spec_helper'
# require 'ruby-debug'

describe StateAdjustment do
  fixtures :all

  it { should validate_presence_of :from }
  it { should validate_presence_of :to }
  it { should validate_presence_of :user }
  it { should validate_presence_of :machine }

  context "creating an adjustment" do
    before(:each) do
      # Incomplete request
      @request = requests(:luke_for_party)
      @updated_at = @request.updated_at
      @state_updated_at = @request.state_updated_at
      @user = users(:supervisor)
      @adjustment = StateAdjustment.new
      @adjustment.user = @user
      @adjustment.machine = @request
    end

    describe "which is valid" do
      before(:each) do
        @adjustment.to = "submitted"
        @adjustment.save
        @request.reload
      end

      it "should be saved" do
        @adjustment.should be_valid
        @adjustment.should_not be_new_record
      end

      it "should change the machine state" do
        @request.state.should == "submitted"
      end

      it "should change both updated_at attributes" do
        @request.updated_at.should > @updated_at
        @request.state_updated_at.should_not == @state_updated_at
      end
    end

    describe "which is not valid" do
      before(:each) do
        # It's already in incomplete state
        @adjustment.to = "incomplete"
        @adjustment.save
        @request.reload
      end

      it "should not be saved" do
        @adjustment.should_not be_valid
        @adjustment.should be_new_record
      end

      it "should not update the machine" do
        @request.updated_at.should == @updated_at
        @request.state_updated_at.should == @state_updated_at
      end
    end
  end
end
