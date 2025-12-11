# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

describe TravelSponsorship do
  let(:request) { described_class.new }

  fixtures :all

  describe '#visa_letter_allowed?' do
    it 'is false for default events' do
      requests(:wedge_for_party).should_not be_visa_letter_allowed
    end

    it 'is true for visa enabled events' do
      request.user = users(:wedge)
      request.event = events(:dagobah_camp)
      request.should be_visa_letter_allowed
    end
  end

  describe '#state_updated_at' do
    before do
      request.user = users(:wedge)
      request.event = events(:dagobah_camp)
      request.save
    end

    it 'is nil for new events' do
      request.state.should == 'incomplete'
      request.state_updated_at.should be_nil
    end

    it 'is updated for on state changes' do
      request.expenses.create(subject: 'Lodging', estimated_amount: 10, estimated_currency: 'USD')
      begin
        transition(request, :submit, users(:wedge))
      rescue
        nil
      end
      request.reload.state.should == 'submitted'
      request.reload.state_updated_at.should_not be_nil
    end
  end

  describe '#only_one_active_request' do
    before do
      request.user = users(:wedge)
    end

    it 'fails trying to save a new request' do
      request.event = events(:party)
      request.save.should eq false
    end

    it "allows saving if it's a new event" do
      request.event = events(:dagobah_camp)
      request.save.should eq true
    end
  end

  describe '#expenses_sum' do
    it ('should be empty if no expenses') { described_class.new.expenses_sum(:estimated).should be_empty }
    it ('should be empty if no values') { requests(:luke_for_yavin).expenses_sum(:total).should be_empty }

    it ('should be zero if 0 values') do
      request = requests(:luke_for_yavin)
      expense = request.expenses.first
      expense.total_amount = 0
      expense.save!
      request.reload
      request.expenses_sum(:total).size.should == 1
      request.expenses_sum(:total)['EUR'].should == 0
    end

    it 'works with just one currency' do
      requests(:luke_for_yavin).expenses_sum(:estimated).size.should == 1
      requests(:luke_for_yavin).expenses_sum(:estimated)['EUR'].should == 260
    end

    it 'works with just several currencies' do
      request = requests(:luke_for_yavin)
      expense = request.expenses.first
      expense.approved_currency = 'AAA'
      amount = expense.approved_amount
      expense.save!
      request.reload
      request.expenses_sum(:approved).size.should == 2
      request.expenses_sum(:approved).first.should == ['AAA', amount]
    end
  end

  context 'when initially submitted' do
    let!(:deliveries) { ActionMailer::Base.deliveries.size }
    let(:request) { requests(:luke_for_party) }
    let(:audits) { request.audits }

    context 'when expenses are incomplete' do
      before do
        request.expenses.create(estimated_amount: 33) # no currency specified
        begin
          transition(request, :submit, users(:luke))
        rescue
          nil
        end
      end

      it 'is not submitted' do
        request.reload.state.should == 'incomplete'
      end
    end

    context 'when submission success' do
      before do
        transition(request, :submit, users(:luke))
      end

      it 'changes the state' do
        request.reload.state.should == 'submitted'
      end

      it 'notifies requester, TSP users and assistants' do
        ActionMailer::Base.deliveries.size.should == deliveries + 3
      end

      it 'audits the change' do
        request.audits.size == audits.size + 1
      end

      it 'creates an state transition' do
        trans = request.transitions.last
        trans.from.should == 'incomplete'
        trans.to.should == 'submitted'
        trans.state_event.should == 'submit'
      end

      it 'allows TSP to roll back' do
        transition(request, :roll_back, users(:tspmember))
        request.state.should == 'incomplete'
        trans = request.transitions.last
        trans.from.should == 'submitted'
        trans.to.should == 'incomplete'
        trans.state_event.should == 'roll_back'
      end

      it 'does not allow TSP to approve with incomplete information' do
        begin
          transition(request, :approve, users(:tspmember))
        rescue
          nil
        end
        request.state.should == 'submitted'
        request.reload.state.should == 'submitted'
      end

      it 'allows TSP to approve' do
        request.expenses.each { |e| e.update_attributes(approved_amount: 40, approved_currency: 'EUR') }
        transition(request, :approve, users(:tspmember))
        request.reload.state.should == 'approved'
        trans = request.transitions.newest_first.reload.first
        trans.from.should == 'submitted'
        trans.to.should == 'approved'
        trans.state_event.should == 'approve'
      end
    end
  end

  describe '#dont_exceed_budget' do
    let(:request) { requests(:wedge_for_party) }
    let(:expense) { request.expenses.create(subject: 'Lodging', estimated_amount: 100, estimated_currency: 'EUR') }

    before do
      request.expenses.first.update_attributes(approved_currency: 'EUR', approved_amount: '70')
    end

    it 'allows approval of a proper amount' do
      expense.update_attributes(approved_amount: 40, approved_currency: 'EUR')
      transition(request, :approve, users(:tspmember))
      request.reload.state.should == 'approved'
    end

    it 'does not allow approval of too large amount' do
      expense.update_attributes(approved_amount: 50, approved_currency: 'eur')
      begin
        transition(request, :approve, users(:tspmember))
      rescue
        nil
      end
      request.reload.state.should == 'submitted'
    end

    it 'uses authorized instead of approved amount if available' do
      reimb = reimbursements(:wedge_for_training_reim)
      reimb.expenses.first.update_attribute(:authorized_amount, 20) # 10 EUR less than the approved amount
      expense.update_attributes(approved_amount: 50, approved_currency: 'EUR')
      begin
        transition(request, :approve, users(:tspmember))
      rescue
        nil
      end
      request.reload.state.should == 'approved'
    end

    it 'ignores requests with canceled reimbursement' do
      reimb = reimbursements(:wedge_for_training_reim)
      reimb.expenses.first.update_attribute(:authorized_amount, 30)
      begin
        transition(reimb, :cancel, users(:wedge))
      rescue
        nil
      end
      reimb.reload.state.should == 'canceled'
      expense.update_attributes(approved_amount: 70, approved_currency: 'EUR')
      begin
        transition(request, :approve, users(:tspmember))
      rescue
        nil
      end
      request.reload.state.should == 'approved'
    end

    it 'does not allow approval with not defined budget at all' do
      request.event.update_attribute(:budget_id, nil)
      expense.update_attributes(approved_amount: 10, approved_currency: 'eur')
      begin
        transition(request, :approve, users(:tspmember))
      rescue
        nil
      end
      request.reload.state.should == 'submitted'
    end

    it 'does not allow approval with not defined budget for the given currency' do
      expense.update_attributes(approved_amount: 10, approved_currency: 'USD')
      begin
        transition(request, :approve, users(:tspmember))
      rescue
        nil
      end
      request.reload.state.should == 'submitted'
    end
  end
end
