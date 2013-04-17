require 'spec_helper'
#require 'ruby-debug'

describe HasStateMailer do
  fixtures :users, :user_profiles, :events, :requests, :request_expenses, :state_transitions

  context "on request approval" do
    before(:each) do
      @request = requests(:wedge_for_party)
      transition(@request, :approve, users(:tspmember))
      @mail = ActionMailer::Base.deliveries.last
    end

    it "should include state in the mail body" do
      @mail.body.encoded.should include @request.human_state_name
    end

    it "should include request url in the mail body" do
      @mail.body.encoded.should match "http.+/requests/#{@request.id}"
    end

    context "and after reimbursement submission" do
      before(:each) do
        @reimbursement = @request.create_reimbursement
        @reimbursement.request.expenses.each {|e| e.total_amount = 55 }
        @reimbursement.save!
        transition(@reimbursement, :submit, users(:wedge))
        @mail = ActionMailer::Base.deliveries.last
      end

      it "should include state in the mail subject" do
        @mail.body.encoded.should include @reimbursement.human_state_name
      end

      it "should include request url in the mail body" do
        @mail.body.encoded.should match "http.+/requests/#{@request.id}/reimbursement"
      end
    end
  end
end
