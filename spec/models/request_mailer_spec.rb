require 'spec_helper'
#require 'ruby-debug'

describe RequestMailer do
  fixtures :all

  context "notifying missing reimbursements with a narrow threshold" do
    before(:each) do
      @mcount = ActionMailer::Base.deliveries.size
      Request.notify_missing_reimbursement 1.day, 10.days
      @request = requests(:luke_for_yavin)
      @mail = ActionMailer::Base.deliveries.last
    end

    it "should mail requester" do
      ActionMailer::Base.deliveries.size.should == @mcount + 1
      @mail.to.should == [@request.user.email]
    end

    it "should have the correct subject" do
      @mail.subject.should == "Missing reimbursement for #{@request.title}"
    end

    it "should include request url in the mail body" do
      @mail.body.encoded.should match "http.+/requests/#{@request.id}"
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

    it "should mail requester" do
      ActionMailer::Base.deliveries.size.should == @mcount + 1
    end
  end
end
