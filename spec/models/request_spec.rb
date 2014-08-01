require 'spec_helper'
#require 'ruby-debug'

describe Request do
  fixtures :all

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

  describe "#state_updated_at" do
    before(:each) do
      @request = Request.new
      @request.user = users(:wedge)
      @request.event = events(:dagobah_camp)
      @request.save
    end

    it "should be nil for new events" do
      @request.state.should == 'incomplete'
      @request.state_updated_at.should be_nil
    end

    it "should be updated for on state changes" do
      @request.expenses.create(:subject => "Lodging", :estimated_amount => 10, :estimated_currency => 'USD')
      transition(@request, :submit, users(:wedge)) rescue nil
      @request.reload.state.should == "submitted"
      @request.reload.state_updated_at.should_not be_nil
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

  context "during initial submission" do
    before(:each) do
      @deliveries = ActionMailer::Base.deliveries.size
      @request = requests(:luke_for_party)
      @audits = @request.audits
    end

    context "if expenses are incomplete" do
      before(:each) do
        @request.expenses.create(:estimated_amount => 33) # no currency specified
        transition(@request, :submit, users(:luke)) rescue nil
      end

      it "should not be submitted" do
        @request.reload.state.should == "incomplete"
      end
    end

    context "if submission success" do
      before(:each) do 
        transition(@request, :submit, users(:luke))
      end

      it "should change the state" do
        @request.reload.state.should == "submitted"
      end

      it "should notify requester, TSP users and assistants" do
        ActionMailer::Base.deliveries.size.should == @deliveries + 3
      end
      
      it "should audit the change" do
        @request.audits.size == @audits.size + 1
      end

      it "should create an state transition" do
        trans = @request.transitions.last
        trans.from.should == "incomplete"
        trans.to.should == "submitted"
        trans.state_event.should == "submit"
      end

      it "should allow TSP to roll back" do
        transition(@request, :roll_back, users(:tspmember))
        @request.state.should == "incomplete"
        trans = @request.transitions.last
        trans.from.should == "submitted"
        trans.to.should == "incomplete"
        trans.state_event.should == "roll_back"
      end

      it "should not allow TSP to approve with incomplete information" do
        transition(@request, :approve, users(:tspmember)) rescue nil
        @request.state.should == "submitted"
        @request.reload.state.should == "submitted"
      end

      it "should allow TSP to approve" do
        @request.expenses.each {|e| e.update_attributes(:approved_amount => 40, :approved_currency => "EUR") }
        transition(@request, :approve, users(:tspmember))
        @request.reload.state.should == "approved"
        trans = @request.transitions.newest_first.reload.first
        trans.from.should == "submitted"
        trans.to.should == "approved"
        trans.state_event.should == "approve"
      end
    end
  end

  describe "#dont_exceed_budget" do
    before(:each) do
      @request = requests(:wedge_for_party)
      @request.expenses.first.update_attributes(:approved_currency => "EUR", :approved_amount => "70")
      @expense = @request.expenses.create(:subject => "Lodging", :estimated_amount => 100, :estimated_currency => "EUR")
    end

    it "should allow approval of a proper amount" do
      @expense.update_attributes(:approved_amount => 40, :approved_currency => "EUR")
      transition(@request, :approve, users(:tspmember))
      @request.reload.state.should == "approved"
    end

    it "should not allow approval of too large amount" do
      @expense.update_attributes(:approved_amount => 50, :approved_currency => "eur")
      transition(@request, :approve, users(:tspmember)) rescue nil
      @request.reload.state.should == "submitted"
    end

    it "should use authorized instead of approved amount if available" do
      reimb = reimbursements(:wedge_for_training_reim)
      reimb.expenses.first.update_attribute(:authorized_amount, 20) # 10 EUR less than the approved amount
      @expense.update_attributes(:approved_amount => 50, :approved_currency => "EUR")
      transition(@request, :approve, users(:tspmember)) rescue nil
      @request.reload.state.should == "approved"
    end

    it "should ignore requests with canceled reimbursement" do
      reimb = reimbursements(:wedge_for_training_reim)
      reimb.expenses.first.update_attribute(:authorized_amount, 30)
      transition(reimb, :cancel, users(:wedge)) rescue nil
      reimb.reload.state.should == 'canceled'
      @expense.update_attributes(:approved_amount => 70, :approved_currency => "EUR")
      transition(@request, :approve, users(:tspmember)) rescue nil
      @request.reload.state.should == "approved"
    end

    it "should not allow approval with not defined budget at all" do
      @request.event.update_attribute(:budget_id, nil)
      @expense.update_attributes(:approved_amount => 10, :approved_currency => "eur")
      transition(@request, :approve, users(:tspmember)) rescue nil
      @request.reload.state.should == "submitted"
    end

    it "should not allow approval with not defined budget for the given currency" do
      @expense.update_attributes(:approved_amount => 10, :approved_currency => "USD")
      transition(@request, :approve, users(:tspmember)) rescue nil
      @request.reload.state.should == "submitted"
    end
  end

  # a spec to ensure that a request without expenses cannot be submitted
  describe "transition from incomplete to submitted" do
    it "should not be allowed if expenses is empty" do
      r=Request.new
      r.user=users(:anakin)
      r.event=events(:yavin_hackaton)
      r.submit
      r.errors[:state].should include "expenses cannot be empty for submit event"
    end
  end

  # a spec to ensure that a change in states or transition events reflects
  # accordingly on the request model
  describe "change in states or transitions" do
    it " should reflect changes in Request model object" do

      s=states(:submitted)
      s.name="submitted_edit"
      s.save

      r=Request.new
      r.state_paths.to_states.should include :submitted_edit
      r.state_paths.to_states.should_not include :submitted
    end
  end

end
