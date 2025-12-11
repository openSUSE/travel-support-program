# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

describe HasStateMailer do
  let(:deliveries_before) { ActionMailer::Base.deliveries.count }
  let(:deliveries) { ActionMailer::Base.deliveries }

  fixtures :all

  context 'when on request approval' do
    let(:request) { requests(:wedge_for_party) }
    let(:mail) { ActionMailer::Base.deliveries.last }

    before do
      request.expenses.each { |e| e.update_attributes(approved_amount: 40, approved_currency: 'EUR') }
      transition(request, :approve, users(:tspmember))
    end

    it 'includes state in the mail body' do
      mail.body.encoded.should include request.human_state_name
    end

    it 'includes request url in the mail body' do
      mail.body.encoded.should match "http.+/travel_sponsorships/#{request.id}"
    end

    context 'with reimbursement submission' do
      let(:reimbursement) { request.create_reimbursement }
      let(:mail) { ActionMailer::Base.deliveries.last }

      before do
        reimbursement.request.expenses.each { |e| e.total_amount = 55 }
        reimbursement.create_bank_account(holder: 'Luke', bank_name: 'Bank',
                                          format: 'iban', iban: 'IBAN', bic: 'BIC')
        set_acceptance_file reimbursement
        reimbursement.save!
        transition(reimbursement, :submit, users(:wedge))
      end

      it 'includes state in the mail subject' do
        mail.body.encoded.should include reimbursement.human_state_name
      end

      it 'includes request url in the mail body' do
        mail.body.encoded.should match "http.+/requests/#{request.id}/reimbursement"
      end
    end
  end

  context 'with never submitted travel sponsorship' do
    before do
      # Delete some irrelevant requests, to keep tests simple
      %i[administrative assistant tspmember].each do |user|
        requests(:"#{user}_for_party").destroy
      end

      deliveries_before
      TravelSponsorship.notify_inactive
    end

    it 'reminds requester' do
      deliveries.count.should == deliveries_before + 1
      deliveries.last.to.should == [users(:luke).email]
    end

    it 'does not include information about last transition' do
      deliveries.last.body.encoded.should_not match 'with the following notes'
    end
  end

  context 'with submitted inactive shipment' do
    before do
      deliveries_before
      Shipment.notify_inactive
    end

    it 'reminds requester and material manager' do
      deliveries.count.should == deliveries_before + 2
      deliveries[-2..-1].map(&:to).should include [users(:wedge).email]
      deliveries[-2..-1].map(&:to).should include [users(:material).email]
    end

    it 'does not include information about last transition' do
      deliveries.last.body.encoded.should match 'with the following notes'
      deliveries.last.body.encoded.should match "I'll take care"
    end
  end

  context 'when checking inactive requests (superclass) and reimbursements' do
    before do
      # Delete some irrelevant requests, to keep tests simple
      %i[administrative assistant tspmember].each do |user|
        requests(:"#{user}_for_party").destroy
        reimbursements(:"#{user}_for_training_reim").destroy
      end

      deliveries_before
      Request.notify_inactive
      Reimbursement.notify_inactive
    end

    it 'reminds everybody delegating to subclasses' do
      deliveries.count.should == deliveries_before + 4
    end
  end
end
