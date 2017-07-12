require 'spec_helper'
# require 'ruby-debug'

describe HasStateMailer do
  fixtures :all

  context 'on request approval' do
    before(:each) do
      @request = requests(:wedge_for_party)
      @request.expenses.each { |e| e.update_attributes(approved_amount: 40, approved_currency: 'EUR') }
      transition(@request, :approve, users(:tspmember))
      @mail = ActionMailer::Base.deliveries.last
    end

    it 'should include state in the mail body' do
      @mail.body.encoded.should include @request.human_state_name
    end

    it 'should include request url in the mail body' do
      @mail.body.encoded.should match "http.+/travel_sponsorships/#{@request.id}"
    end

    context 'and after reimbursement submission' do
      before(:each) do
        @reimbursement = @request.create_reimbursement
        @reimbursement.request.expenses.each { |e| e.total_amount = 55 }
        @reimbursement.create_bank_account(holder: 'Luke', bank_name: 'Bank',
                                           format: 'iban', iban: 'IBAN', bic: 'BIC')
        set_acceptance_file @reimbursement
        @reimbursement.save!
        transition(@reimbursement, :submit, users(:wedge))
        @mail = ActionMailer::Base.deliveries.last
      end

      it 'should include state in the mail subject' do
        @mail.body.encoded.should include @reimbursement.human_state_name
      end

      it 'should include request url in the mail body' do
        @mail.body.encoded.should match "http.+/requests/#{@request.id}/reimbursement"
      end
    end
  end

  context 'with never submitted travel sponsorship' do
    before(:each) do
      # Delete some irrelevant requests, to keep tests simple
      [:administrative, :assistant, :tspmember, :josh].each do |user|
        requests(:"#{user}_for_party").destroy
      end

      @deliveries_before = ActionMailer::Base.deliveries.count
      TravelSponsorship.notify_inactive
      @deliveries = ActionMailer::Base.deliveries
    end

    it 'should remind requester' do
      @deliveries.count.should == @deliveries_before + 1
      @deliveries.last.to.should == [users(:luke).email]
    end

    it 'should not include information about last transition' do
      @deliveries.last.body.encoded.should_not match 'with the following notes'
    end
  end

  context 'with submitted inactive shipment' do
    before(:each) do
      @deliveries_before = ActionMailer::Base.deliveries.count
      Shipment.notify_inactive
      @deliveries = ActionMailer::Base.deliveries
    end

    it 'should remind requester and material manager' do
      @deliveries.count.should == @deliveries_before + 2
      @deliveries[-2..-1].map(&:to).should include [users(:wedge).email]
      @deliveries[-2..-1].map(&:to).should include [users(:material).email]
    end

    it 'should not include information about last transition' do
      @deliveries.last.body.encoded.should match 'with the following notes'
      @deliveries.last.body.encoded.should match "I'll take care"
    end
  end

  context 'checking inactive requests (superclass) and reimbursements' do
    before(:each) do
      # Delete some irrelevant requests, to keep tests simple
      [:administrative, :assistant, :tspmember].each do |user|
        requests(:"#{user}_for_party").destroy
        reimbursements(:"#{user}_for_training_reim").destroy
      end

      @deliveries_before = ActionMailer::Base.deliveries.count
      Request.notify_inactive
      Reimbursement.notify_inactive
      @deliveries = ActionMailer::Base.deliveries
    end

    it 'should remind everybody delegating to subclasses' do
      @deliveries.count.should == @deliveries_before + 5
    end
  end
end
