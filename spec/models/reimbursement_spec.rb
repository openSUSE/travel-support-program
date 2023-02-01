# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

describe Reimbursement do
  let(:reimbursement) { requests(:luke_for_yavin).create_reimbursement }
  let!(:deliveries) { ActionMailer::Base.deliveries.size }

  fixtures :all

  context 'when initially submitted' do
    before do
      reimbursement.request.expenses.each { |e| e.total_amount = 55 }
      set_acceptance_file reimbursement
      reimbursement.build_bank_account(holder: 'Owen Lars', bank_name: 'Tatooine Saving Bank',
                                       format: 'iban', iban: 'AT611904300234574444',
                                       bic: 'ABCDEABCDE')
      reimbursement.save!
      transition(reimbursement, :submit, users(:luke))
    end

    it 'calculates correctly the authorized amounts' do
      reimbursement.expenses.reload.map { |i| i.authorized_amount.to_f }.sort.should == [0.0, 50.0, 55.0]
    end

    it 'notifies requester, TSP users and assistants' do
      ActionMailer::Base.deliveries.size.should == deliveries + 3
    end

    context 'with finished negotiation' do
      before do
        reimbursement.reload
        transition(reimbursement, :roll_back, users(:tspmember))
        reimbursement.request.expenses.each { |e| e.total_amount = 80 }
        reimbursement.save!
        transition(reimbursement, :submit, users(:luke))
      end

      it 'recalculates authorized amounts' do
        reimbursement.expenses.reload.map { |i| i.authorized_amount.to_f }.sort.should == [0.0, 50.0, 60.0]
      end

      it 'notifies negotiation steps to requester, TSP and assistants' do
        ActionMailer::Base.deliveries.size.should == deliveries + 9
      end

      context 'with approval' do
        before do
          transition(reimbursement, :approve, users(:tspmember))
        end

        it 'does not change the authorized amounts' do
          reimbursement.expenses.reload.map { |i| i.authorized_amount.to_f }.sort.should == [0.0, 50.0, 60.0]
        end

        it 'notifies approval to requester, TSP, assistants and administrative' do
          ActionMailer::Base.deliveries.size.should == deliveries + 13
        end
      end
    end
  end

  context 'when submitting with incomplete profile' do
    let(:user) { users(:luke) }

    before do
      user.profile.location = nil
      user.profile.save!
      reimbursement.request.expenses.each { |e| e.total_amount = 55 }
      set_acceptance_file reimbursement
      reimbursement.build_bank_account(holder: 'Owen Lars', bank_name: 'Tatooine Saving Bank',
                                       format: 'iban', iban: 'AT611904300234574444',
                                       bic: 'ABCDEABCDE')
      reimbursement.save!
    end

    it 'fails' do
      expect { transition(reimbursement, :submit, users(:luke)) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context 'when fixing the profile' do
      before do
        user.profile.update_attribute :location, 'Nomad'
      end

      it 'successes' do
        transition(reimbursement, :submit, users(:luke))
        reimbursement.submitted?.should eq true
      end
    end
  end

  context 'when mixing currencies' do
    let(:request) { requests(:luke_for_yavin) }
    let(:reimbursement) { request.create_reimbursement }

    before do
      request.expenses.where(subject: 'Lodging').first.update_column(:estimated_currency, 'USD')
      reimbursement.request.expenses.each { |e| e.total_amount = 55 }
      set_acceptance_file reimbursement
      reimbursement.build_bank_account(holder: 'Owen Lars', bank_name: 'Tatooine Saving Bank',
                                       format: 'iban', iban: 'AT611904300234574444',
                                       bic: 'ABCDEABCDE')
      reimbursement.save!
    end

    it 'calculates the authorized only when possible' do
      reimbursement.expenses.where(subject: 'Lodging').first.authorized_amount.should be_nil
      reimbursement.expenses.reload.map { |i| i.authorized_amount.to_f }.sort.should == [0.0, 0.0, 55.0]
    end

    it 'is not possible to submit without setting the authorized manually' do
      begin
        transition(reimbursement, :submit, users(:luke))
      rescue
        nil
      end
      reimbursement.reload.state.should == 'incomplete'
    end

    it 'overrides authorized amount for some expenses and respect the manual ones' do
      reimbursement.request.expenses.each { |e| e.authorized_amount = 25 }
      reimbursement.save!
      reimbursement.expenses.reload.map { |i| i.authorized_amount.to_f }.sort.should == [0.0, 25.0, 55.0]
    end
  end
end
