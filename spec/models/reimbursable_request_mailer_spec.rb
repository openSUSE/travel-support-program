# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

describe ReimbursableRequestMailer do
  let!(:mcount) { ActionMailer::Base.deliveries.size }

  fixtures :all

  before do
    # Delete all affected requests but Luke's one, to keep tests simple
    %i[administrative assistant tspmember].each do |user|
      requests(:"#{user}_for_yavin").destroy
    end
  end

  context 'when notifying missing reimbursements with a narrow threshold' do
    let!(:request) { requests(:luke_for_yavin) }
    let(:mail) { ActionMailer::Base.deliveries.last }

    before do
      TravelSponsorship.notify_missing_reimbursement 1.day, 10.days
    end

    it 'mails requester' do
      ActionMailer::Base.deliveries.size.should == mcount + 1
      mail.to.should == [request.user.email]
    end

    it 'has the correct subject' do
      mail.subject.should == "Missing reimbursement for #{request.title}"
    end

    it 'includes request url in the mail body' do
      mail.body.encoded.should match "http.+/travel_sponsorships/#{request.id}"
    end
  end

  context 'when notifying missing reimbursements with a big threshold' do
    before do
      TravelSponsorship.notify_missing_reimbursement 10.days, 11.days
    end

    it 'mails nobody' do
      ActionMailer::Base.deliveries.size.should == mcount
    end
  end

  context 'when notifying missing reimbursements based on reimbursement deadline' do
    before do
      event = events(:yavin_hackaton)
      event.update_attribute(:reimbursement_creation_deadline, 10.days.since)
      TravelSponsorship.notify_missing_reimbursement 10.days, 11.days
    end

    it 'mails requester' do
      ActionMailer::Base.deliveries.size.should == mcount + 1
    end
  end
end
