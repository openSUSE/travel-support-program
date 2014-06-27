require 'spec_helper'
require 'cancan/matchers'
#require 'ruby-debug'

describe "Assistant" do
  fixtures :all

  subject { Ability.new(user) }
  let(:user){ users(:assistant) }

  context 'managing budgets' do
    it{ should_not be_able_to(:create, Budget.new) }
    it{ should be_able_to(:read, budgets(:general_budget)) }
    it{ should_not be_able_to(:update, budgets(:general_budget)) }
    it{ should_not be_able_to(:destroy, budgets(:general_budget)) }
  end

  context 'managing events' do
    it{ should be_able_to(:create, Event.new) }
    it{ should_not be_able_to(:update, events(:yavin_hackaton)) }
    it{ should be_able_to(:update, events(:party)) }
    it{ should_not be_able_to(:destroy, events(:yavin_hackaton)) }
    it{ should_not be_able_to(:destroy, events(:party)) }
  end

  context 'managing requests' do
    it{ should_not be_able_to(:create, Request.new) }
    it{ should be_able_to(:read, requests(:wedge_for_party)) }
    it{ should be_able_to(:read, requests(:luke_for_yavin)) }
    it{ should_not be_able_to(:update, requests(:wedge_for_party)) }
    it{ should_not be_able_to(:approve, requests(:wedge_for_party)) }
    it{ should_not be_able_to(:roll_back, requests(:wedge_for_party)) }
    it{ should_not be_able_to(:update, requests(:luke_for_yavin)) }
    it{ should_not be_able_to(:destroy, requests(:luke_for_party)) }
    it{ should_not be_able_to(:destroy, requests(:luke_for_yavin)) }
    it{ should_not be_able_to(:cancel, requests(:luke_for_party)) }
    it{ should_not be_able_to(:cancel, requests(:wedge_for_party)) }
    it{ should_not be_able_to(:cancel, requests(:luke_for_yavin)) }
    it{ should_not be_able_to(:adjust_state, requests(:luke_for_party)) }
    it{ should_not be_able_to(:adjust_state, requests(:wedge_for_party)) }
    it{ should_not be_able_to(:adjust_state, requests(:luke_for_yavin)) }
  end

  context "managing reimbursements" do
    before(:each) do
      @reimbursement = requests(:luke_for_yavin).create_reimbursement
      @reimbursement.request.expenses.each do |e|
        e.total_amount = e.estimated_amount + 5
      end
      set_acceptance_file @reimbursement
      @reimbursement.create_bank_account(:holder => "Luke", :bank_name => "Bank",
                                         :format => "iban", :iban => "IBAN", :bic => "BIC")
    end

    it{ should_not be_able_to(:create, Reimbursement.new) }
    it{ should be_able_to(:read, @reimbursement) }
    it{ should_not be_able_to(:update, @reimbursement) }
    it{ should_not be_able_to(:approve, @reimbursement) }
    it{ should_not be_able_to(:roll_back, @reimbursement) }
    it{ should_not be_able_to(:cancel, @reimbursement) }
    it{ should_not be_able_to(:destroy, @reimbursement) }
    it{ should_not be_able_to(:process, @reimbursement) }
    it{ should_not be_able_to(:confirm, @reimbursement) }
    it{ should_not be_able_to(:adjust_state, @reimbursement) }
  end

  context 'adding comments to requests' do
    it{ should be_able_to(:create, requests(:luke_for_yavin).comments.build) }
    it{ should be_able_to(:create, requests(:luke_for_yavin).comments.build(:private => true)) }
  end

  context 'accessing public comments on requests' do
    before(:each) do
      @comment = requests(:luke_for_yavin).comments.create(:body => "whatever")
    end

    it{ should be_able_to(:read, @comment) }
    it{ should_not be_able_to(:destroy, @comment) }
    it{ should_not be_able_to(:update, @comment) }
  end

  context 'accessing private comments on requests' do
    before(:each) do
      @comment = requests(:luke_for_yavin).comments.create(:body => "whatever", :private => true)
    end

    it{ should be_able_to(:read, @comment) }
    it{ should_not be_able_to(:destroy, @comment) }
    it{ should_not be_able_to(:update, @comment) }
  end

  context 'accessing attachments in a reimbursement' do
    before(:each) do
      @reimbursement = reimbursements(:wedge_for_training_reim)
    end

    it{ should be_able_to(:read, @reimbursement.attachments.first) }
    it{ should_not be_able_to(:destroy, @reimbursement.attachments.first) }
    it{ should_not be_able_to(:update, @reimbursement.attachments.first) }
    it{ should_not be_able_to(:create, @reimbursement.attachments.build) }
  end

  context 'accessing shipments' do
    it{ should_not be_able_to(:create, Shipment.new) }
    it{ should_not be_able_to(:read, shipments(:wedge_customes_for_party)) }
    it{ should_not be_able_to(:update, shipments(:wedge_customes_for_party)) }
    it{ should_not be_able_to(:destroy, shipments(:wedge_customes_for_party)) }
  end
end
