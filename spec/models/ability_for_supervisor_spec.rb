# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'
# require 'ruby-debug'

describe 'Supervisor' do
  fixtures :all

  subject { Ability.new(user) }
  let(:user) { users(:supervisor) }

  context 'managing budgets' do
    it { should be_able_to(:create, Budget.new) }
    it { should be_able_to(:read, budgets(:general_budget)) }
    it { should be_able_to(:update, budgets(:general_budget)) }
    it { should be_able_to(:destroy, budgets(:general_budget)) }
  end

  context 'managing events' do
    it { should be_able_to(:create, Event.new) }
    it { should be_able_to(:update, events(:yavin_hackaton)) }
    it { should be_able_to(:update, events(:party)) }
    it { should_not be_able_to(:destroy, events(:yavin_hackaton)) }
    it { should_not be_able_to(:destroy, events(:party)) }
  end

  context 'managing event emails' do
    it { should_not be_able_to(:create, EventEmail.new) }
    it { should_not be_able_to(:read, event_emails(:party_info)) }
  end

  context 'managing event organizers' do
    it { should_not be_able_to(:create, EventOrganizer.new) }
    it { should_not be_able_to(:read, event_organizers(:event_org_luke)) }
  end

  context 'managing requests' do
    it { should_not be_able_to(:create, Request.new) }
    it { should be_able_to(:read, requests(:wedge_for_party)) }
    it { should be_able_to(:read, requests(:luke_for_yavin)) }
    it { should be_able_to(:adjust_state, requests(:luke_for_yavin)) }
    it { should be_able_to(:adjust_state, requests(:wedge_for_party)) }
    it { should be_able_to(:cancel, requests(:luke_for_party)) }
    it { should be_able_to(:cancel, requests(:wedge_for_party)) }
    it { should be_able_to(:cancel, requests(:luke_for_yavin)) }
    it { should_not be_able_to(:update, requests(:wedge_for_party)) }
    it { should_not be_able_to(:approve, requests(:wedge_for_party)) }
    it { should_not be_able_to(:roll_back, requests(:wedge_for_party)) }
    it { should_not be_able_to(:update, requests(:luke_for_yavin)) }
    it { should_not be_able_to(:destroy, requests(:luke_for_party)) }
    it { should_not be_able_to(:destroy, requests(:luke_for_yavin)) }
  end

  context 'managing reimbursements' do
    before(:each) do
      @reimbursement = requests(:luke_for_yavin).create_reimbursement
      set_acceptance_file @reimbursement
      @reimbursement.request.expenses.each do |e|
        e.total_amount = e.estimated_amount + 5
      end
    end

    it { should be_able_to(:read, @reimbursement) }
    it { should be_able_to(:adjust_state, @reimbursement) }
    it { should be_able_to(:cancel, @reimbursement) }
    it { should_not be_able_to(:update, @reimbursement) }
    it { should_not be_able_to(:approve, @reimbursement) }
    it { should_not be_able_to(:roll_back, @reimbursement) }
    it { should_not be_able_to(:destroy, @reimbursement) }
    it { should_not be_able_to(:process, @reimbursement) }
    it { should_not be_able_to(:confirm, @reimbursement) }
  end

  context 'adding comments to requests' do
    it { should be_able_to(:create, requests(:luke_for_yavin).comments.build) }
    it { should be_able_to(:create, requests(:luke_for_yavin).comments.build(private: true)) }
  end

  context 'accessing public comments on requests' do
    before(:each) do
      @comment = requests(:luke_for_yavin).comments.create(body: 'whatever')
    end

    it { should be_able_to(:read, @comment) }
    it { should_not be_able_to(:destroy, @comment) }
    it { should_not be_able_to(:update, @comment) }
  end

  context 'accessing private comments on requests' do
    before(:each) do
      @comment = requests(:luke_for_yavin).comments.create(body: 'whatever', private: true)
    end

    it { should be_able_to(:read, @comment) }
    it { should_not be_able_to(:destroy, @comment) }
    it { should_not be_able_to(:update, @comment) }
  end

  context 'accessing attachments in a reimbursement' do
    before(:each) do
      @reimbursement = reimbursements(:wedge_for_training_reim)
      set_acceptance_file @reimbursement
    end

    it { should be_able_to(:read, @reimbursement.attachments.first) }
    it { should_not be_able_to(:destroy, @reimbursement.attachments.first) }
    it { should_not be_able_to(:update, @reimbursement.attachments.first) }
    it { should_not be_able_to(:create, @reimbursement.attachments.build) }

    context 'after submitting it' do
      before(:each) do
        transition(@reimbursement, :submit, users(:wedge))
      end

      it { should be_able_to(:read, @reimbursement.attachments.first) }
      it { should_not be_able_to(:destroy, @reimbursement.attachments.first) }
      it { should_not be_able_to(:update, @reimbursement.attachments.first) }
      it { should_not be_able_to(:create, @reimbursement.attachments.build) }
    end
  end

  context 'managing shipments' do
    it { should_not be_able_to(:create, Shipment.new) }
    it { should be_able_to(:read, requests(:wedge_costumes_for_party)) }
    it { should be_able_to(:read, requests(:luke_costumes_for_party)) }
    it { should be_able_to(:adjust_state, requests(:wedge_costumes_for_party)) }
    it { should be_able_to(:cancel, requests(:luke_costumes_for_party)) }
    it { should_not be_able_to(:update, requests(:wedge_costumes_for_party)) }
    it { should_not be_able_to(:approve, requests(:wedge_costumes_for_party)) }
    it { should_not be_able_to(:roll_back, requests(:wedge_costumes_for_party)) }
    it { should_not be_able_to(:update, requests(:luke_costumes_for_party)) }
    it { should_not be_able_to(:destroy, requests(:wedge_costumes_for_party)) }
    it { should_not be_able_to(:destroy, requests(:luke_costumes_for_party)) }
  end

  context 'adding comments to shipments' do
    it { should be_able_to(:create, requests(:luke_costumes_for_party).comments.build) }
    it { should be_able_to(:create, requests(:luke_costumes_for_party).comments.build(private: true)) }
  end
end
