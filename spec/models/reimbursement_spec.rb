require 'spec_helper'
#require 'ruby-debug'

describe Reimbursement do
  fixtures :users, :user_profiles, :events, :requests, :request_expenses, :state_transitions

  context "during initial submission" do
    before(:each) do
      @deliveries = ActionMailer::Base.deliveries.size
      @reimbursement = requests(:luke_for_yavin).create_reimbursement
      @reimbursement.request.expenses.each {|e| e.total_amount = 55 }
      @reimbursement.save!
      transition(@reimbursement, :submit, users(:luke))
    end

    it "should calculate correctly the authorized amounts" do
      @reimbursement.expenses.reload.map {|i| i.authorized_amount.to_f}.sort.should == [0.0, 50.0, 55.0]
    end

    it "should notify requester and TSP users" do
      ActionMailer::Base.deliveries.size.should == @deliveries + 2
    end

    context "after negotiation" do
      before(:each) do
        @reimbursement.reload
        @reimbursement.request.expenses.each {|e| e.authorized_amount = 10 }
        @reimbursement.save!
        transition(@reimbursement, :roll_back, users(:tspmember))
        @reimbursement.request.expenses.each {|e| e.total_amount = 80 }
        @reimbursement.save!
        transition(@reimbursement, :submit, users(:luke))
      end

      it "should not override the manually set authorized amounts" do
        @reimbursement.expenses.reload.map {|i| i.authorized_amount.to_f}.sort.should == [10.0, 10.0, 10.0]
      end

      it "should notify approval to requester, TSP and administrative" do
        ActionMailer::Base.deliveries.size.should == @deliveries + 6
        transition(@reimbursement, :approve, users(:tspmember))
        ActionMailer::Base.deliveries.size.should == @deliveries + 9
      end
    end
  end
end
