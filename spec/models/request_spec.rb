require 'spec_helper'
require 'ruby-debug'

describe Request do
  # TODO
  # * Creation of correct StateTransition objects
  # * assign_state
  # * trying to submit incomplete requests
  fixtures :users, :user_profiles, :events, :requests, :request_expenses, :state_transitions

  describe "#visa_letter_allowed?" do
    it "should be false for default events" do
      requests(:wedge_for_party).should_not be_visa_letter_allowed
    end
    it "should be true for visa enabled events" do
      r = Request.new
      r.user = users(:wedge)
      r.event = events(:dagobah_camp)
      r.should be_visa_letter_allowed
    end
  end

  describe "#only_one_active_request" do
    before(:each) do
      @request = Request.new
      @request.user = users(:wedge)
    end

    it "should fail trying to save a new request" do
      @request.event = events(:party)
      @request.save.should be_false
    end

    it "should allow saving if it's a new event" do
      @request.event = events(:dagobah_camp)
      @request.save.should be_true
    end
  end

  describe "#expenses_sum" do
    it ("should be empty if no expenses") { Request.new.expenses_sum(:estimated).should be_empty }
    it ("should be empty if no values") { requests(:luke_for_yavin).expenses_sum(:total).should be_empty }
    it ("should be zero if 0 values") do
      request = requests(:luke_for_yavin)
      expense = request.expenses.first
      expense.total_amount = 0
      expense.save!
      request.reload
      request.expenses_sum(:total).size.should == 1
      request.expenses_sum(:total)["EUR"].should == 0
    end
    it "should work with just one currency" do
      requests(:luke_for_yavin).expenses_sum(:estimated).size.should == 1
      requests(:luke_for_yavin).expenses_sum(:estimated)["EUR"].should == 260
    end
    it "should work with just several currencies" do
      request = requests(:luke_for_yavin)
      expense = request.expenses.first
      expense.approved_currency = "AAA"
      amount = expense.approved_amount
      expense.save!
      request.reload
      request.expenses_sum(:approved).size.should == 2
      request.expenses_sum(:approved).first.should == ["AAA", amount]
    end
  end
end
