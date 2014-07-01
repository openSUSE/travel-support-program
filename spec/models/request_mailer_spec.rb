require 'spec_helper'
#require 'ruby-debug'

describe RequestMailer do
  fixtures :all

  context "notifying missing reimbursements with a narrow threshold" do
    before(:each) do
      @mcount = ActionMailer::Base.deliveries.size
      Request.notify_missing_reimbursement 1.day, 10.days
      @request = requests(:luke_for_yavin)
      @mails = ActionMailer::Base.deliveries[-3..-1]
    end

    it "should mail requester, tsp and assistant" do
      ActionMailer::Base.deliveries.size.should == @mcount + 3
      @mails.map(&:to).flatten.should include @request.user.email
    end

    it "should include request url in the mail body" do
      @mails.first.body.encoded.should match "http.+/requests/#{@request.id}"
    end
  end

  context "notifying missing reimbursements with a big threshold" do
    before(:each) do
      @mcount = ActionMailer::Base.deliveries.size
      Request.notify_missing_reimbursement 10.days, 11.days
    end

    it "should mail nobody" do
      ActionMailer::Base.deliveries.size.should == @mcount
    end
  end

  context "notifying missing reimbursements based on reimbursement deadline" do
    before(:each) do
      @mcount = ActionMailer::Base.deliveries.size
      event = events(:yavin_hackaton)
      event.update_attribute(:reimbursement_creation_deadline, 10.days.since)
      Request.notify_missing_reimbursement 10.days, 11.days
    end

    it "should mail requester, tsp and assistant" do
      ActionMailer::Base.deliveries.size.should == @mcount+3
    end
  end
end
