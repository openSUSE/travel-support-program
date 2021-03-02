require 'spec_helper'
require 'cancan/matchers'
# require 'ruby-debug'

describe 'Requester' do
  fixtures :all

  subject { Ability.new(user) }
  let(:user) { users(:luke) }

  context 'managing budgets' do
    it { should_not be_able_to(:create, Budget.new) }
    it { should_not be_able_to(:read, budgets(:general_budget)) }
    it { should_not be_able_to(:update, budgets(:general_budget)) }
    it { should_not be_able_to(:destroy, budgets(:general_budget)) }
  end

  context 'managing events' do
    it { should be_able_to(:create, Event.new) }
    it { should_not be_able_to(:update, events(:yavin_hackaton)) }
    it { should be_able_to(:update, events(:party)) }
    it { should_not be_able_to(:destroy, events(:yavin_hackaton)) }
    it { should_not be_able_to(:destroy, events(:party)) }
  end

  context 'managing event emails' do
    context 'is an event organizer' do
      it { should_not be_able_to(:create, EventEmail.new(event_id: events(:dagobah_camp).id)) }
      it { should be_able_to(:create, EventEmail.new(event_id: events(:party).id)) }
      it { should be_able_to(:read, event_emails(:party_info)) }
    end

    context 'is not a event organizer' do
      let(:user) { users(:wedge) }
      it { should_not be_able_to(:create, EventEmail.new) }
      it { should_not be_able_to(:read, event_emails(:party_info)) }
    end
  end

  context 'managing event organizers' do
    it { should_not be_able_to(:create, EventOrganizer.new) }
    it { should_not be_able_to(:read, event_organizers(:event_org_luke)) }
  end

  context 'managing their own requests' do
    it { should_not be_able_to(:create, TravelSponsorship.new) }
    it { should be_able_to(:create, TravelSponsorship.new(event_id: events(:dagobah_camp).id)) }
    it { should_not be_able_to(:create, TravelSponsorship.new(event_id: events(:hoth_hackaton).id)) }
    it { should be_able_to(:read, requests(:luke_for_party)) }
    it { should be_able_to(:read, requests(:luke_for_yavin)) }
    it { should be_able_to(:update, requests(:luke_for_party)) }
    it { should_not be_able_to(:update, requests(:luke_for_yavin)) }
    it { should be_able_to(:destroy, requests(:luke_for_party)) }
    it { should_not be_able_to(:destroy, requests(:luke_for_yavin)) }
    it { should be_able_to(:cancel, requests(:luke_for_party)) }
    it { should be_able_to(:cancel, requests(:luke_for_yavin)) }
    it { should_not be_able_to(:adjust_state, requests(:luke_for_yavin)) }
    it { should_not be_able_to(:adjust_state, requests(:luke_for_party)) }
  end

  context "trying to look into other's requests" do
    context 'is an event organizer' do
      it { should_not be_able_to(:read, requests(:wedge_for_yavin)) }
      it { should be_able_to(:read, requests(:wedge_for_party)) }
    end

    context 'is not an event organizer' do
      let(:user) { users(:anakin) }
      it { should_not be_able_to(:read, requests(:wedge_for_yavin)) }
      it { should_not be_able_to(:read, requests(:wedge_for_party)) }
    end

    it { should_not be_able_to(:update, requests(:wedge_for_party)) }
    it { should_not be_able_to(:adjust_state, requests(:wedge_for_party)) }
  end

  context 'asking for a correct reimbursement' do
    it { should be_able_to(:create, requests(:luke_for_yavin).build_reimbursement) }
  end

  context 'asking for an incorrect reimbursement' do
    let(:user) { users(:wedge) }
    it { should_not be_able_to(:create, requests(:luke_for_yavin).build_reimbursement) }
    it { should_not be_able_to(:create, requests(:wedge_for_yavin).build_reimbursement) }
  end

  context 'managing a reimbursement' do
    before(:each) do
      @reimbursement = requests(:luke_for_yavin).create_reimbursement
      @reimbursement.request.expenses.each do |e|
        e.total_amount = e.estimated_amount + 5
      end
      set_acceptance_file @reimbursement
      @reimbursement.create_bank_account(holder: 'luke', bank_name: 'Bank',
                                         format: 'iban', iban: 'IBAN', bic: 'BIC')
    end

    it { should be_able_to(:submit, @reimbursement) }
    it { should be_able_to(:update, @reimbursement) }
    it { should be_able_to(:cancel, @reimbursement) }
    it { should_not be_able_to(:approve, @reimbursement) }
    it { should_not be_able_to(:process, @reimbursement) }
    it { should_not be_able_to(:confirm, @reimbursement) }
    it { should_not be_able_to(:adjust_state, @reimbursement) }

    context "and trying to look into other's reimbursements" do
      let(:user) { users(:wedge) }
      it { should_not be_able_to(:read, @reimbursement) }
      it { should_not be_able_to(:update, @reimbursement) }
      it { should_not be_able_to(:submit, @reimbursement) }
      it { should_not be_able_to(:cancel, @reimbursement) }
      it { should_not be_able_to(:approve, @reimbursement) }
      it { should_not be_able_to(:process, @reimbursement) }
      it { should_not be_able_to(:confirm, @reimbursement) }
      it { should_not be_able_to(:adjust_state, @reimbursement) }
    end

    context 'already submitted' do
      before(:each) do
        @reimbursement.submit!
      end

      it { should be_able_to(:read, @reimbursement) }
      it { should be_able_to(:roll_back, @reimbursement) }
      it { should be_able_to(:cancel, @reimbursement) }
      it { should_not be_able_to(:update, @reimbursement) }
      it { should_not be_able_to(:approve, @reimbursement) }
      it { should_not be_able_to(:process, @reimbursement) }
      it { should_not be_able_to(:confirm, @reimbursement) }
      it { should_not be_able_to(:destroy, @reimbursement) }
      it { should_not be_able_to(:adjust_state, @reimbursement) }

      context 'and approved' do
        before(:each) do
          @reimbursement.approve!
        end

        it { should be_able_to(:read, @reimbursement) }
        it { should be_able_to(:cancel, @reimbursement) }
        it { should be_able_to(:roll_back, @reimbursement) }
        it { should_not be_able_to(:update, @reimbursement) }
        it { should_not be_able_to(:destroy, @reimbursement) }
        it { should_not be_able_to(:approve, @reimbursement) }
        it { should_not be_able_to(:process, @reimbursement) }
        it { should_not be_able_to(:confirm, @reimbursement) }
        it { should_not be_able_to(:adjust_state, @reimbursement) }

        context 'and processed' do
          before(:each) do
            @reimbursement.process!
          end

          it { should be_able_to(:read, @reimbursement) }
          it { should_not be_able_to(:update, @reimbursement) }
          it { should_not be_able_to(:destroy, @reimbursement) }
          it { should_not be_able_to(:cancel, @reimbursement) }
          it { should_not be_able_to(:approve, @reimbursement) }
          it { should_not be_able_to(:roll_back, @reimbursement) }
          it { should_not be_able_to(:process, @reimbursement) }
          it { should_not be_able_to(:confirm, @reimbursement) }
          it { should_not be_able_to(:adjust_state, @reimbursement) }

          context 'and payed' do
            before(:each) do
              @reimbursement.confirm!
            end

            it { should be_able_to(:read, @reimbursement) }
            it { should_not be_able_to(:update, @reimbursement) }
            it { should_not be_able_to(:destroy, @reimbursement) }
            it { should_not be_able_to(:cancel, @reimbursement) }
            it { should_not be_able_to(:approve, @reimbursement) }
            it { should_not be_able_to(:roll_back, @reimbursement) }
            it { should_not be_able_to(:process, @reimbursement) }
            it { should_not be_able_to(:confirm, @reimbursement) }
            it { should_not be_able_to(:adjust_state, @reimbursement) }
          end
        end
      end
    end
  end

  context 'adding comments to their own requests' do
    it { should be_able_to(:create, requests(:luke_for_yavin).comments.build) }
    it { should_not be_able_to(:create, requests(:luke_for_yavin).comments.build(private: true)) }
  end

  context 'accessing public comments on their own requests' do
    before(:each) do
      @comment = requests(:luke_for_yavin).comments.create(body: 'whatever')
    end

    it { should be_able_to(:read, @comment) }
    it { should_not be_able_to(:destroy, @comment) }
    it { should_not be_able_to(:update, @comment) }
  end

  context 'accessing private comments on their own requests' do
    before(:each) do
      @comment = requests(:luke_for_yavin).comments.create(body: 'whatever', private: true)
    end

    it { should_not be_able_to(:read, @comment) }
    it { should_not be_able_to(:destroy, @comment) }
    it { should_not be_able_to(:update, @comment) }
  end

  context "adding comments to other's requests" do
    it { should_not be_able_to(:create, requests(:wedge_for_party).comments.build) }
  end

  context "accessing comments on other's requests" do
    before(:each) do
      @comment = requests(:wedge_for_yavin).comments.create(body: 'whatever')
    end

    it { should_not be_able_to(:read, @comment) }
    it { should_not be_able_to(:destroy, @comment) }
    it { should_not be_able_to(:update, @comment) }
  end

  context 'manage attachments to their own reimbursements' do
    before(:each) do
      @reimbursement = reimbursements(:wedge_for_training_reim)
      set_acceptance_file @reimbursement
    end
    let(:user) { users(:wedge) }

    it { should be_able_to(:read, @reimbursement.attachments.first) }
    it { should be_able_to(:destroy, @reimbursement.attachments.first) }
    it { should be_able_to(:update, @reimbursement.attachments.first) }
    it { should be_able_to(:create, @reimbursement.attachments.build) }

    context 'after submitting it' do
      before(:each) do
        transition(@reimbursement, :submit, users(:wedge))
      end

      it { should be_able_to(:read, @reimbursement.attachments.first) }
      it { should_not be_able_to(:destroy, @reimbursement.attachments.first) }
      it { should_not be_able_to(:update, @reimbursement.attachments.first) }
      it { should_not be_able_to(:create, @reimbursement.attachments.build) }
    end

    context "and trying to look into other's reimbursements" do
      let(:user) { users(:luke) }
      it { should_not be_able_to(:read, @reimbursement.attachments.first) }
      it { should_not be_able_to(:destroy, @reimbursement.attachments.first) }
      it { should_not be_able_to(:update, @reimbursement.attachments.first) }
      it { should_not be_able_to(:create, @reimbursement.attachments.build) }
    end
  end

  context 'managing their own shipments' do
    it { should_not be_able_to(:create, Shipment.new) }
    it { should be_able_to(:create, Shipment.new(event_id: events(:hoth_hackaton).id)) }
    it { should_not be_able_to(:create, Shipment.new(event_id: events(:dagobah_camp).id)) }
    it { should be_able_to(:read, requests(:luke_costumes_for_party)) }
    it { should be_able_to(:update, requests(:luke_costumes_for_party)) }
    it { should be_able_to(:destroy, requests(:luke_costumes_for_party)) }
    it { should be_able_to(:cancel, requests(:luke_costumes_for_party)) }
    it { should_not be_able_to(:adjust_state, requests(:luke_costumes_for_party)) }
  end

  context "trying to look into other's requests" do
    it { should_not be_able_to(:read, requests(:wedge_costumes_for_party)) }
    it { should_not be_able_to(:update, requests(:wedge_costumes_for_party)) }
    it { should_not be_able_to(:adjust_state, requests(:wedge_costumes_for_party)) }
  end

  context 'managing their own requested shipments' do
    let(:user) { users(:wedge) }

    it { should be_able_to(:read, requests(:wedge_costumes_for_party)) }
    it { should_not be_able_to(:update, requests(:wedge_costumes_for_party)) }
    it { should_not be_able_to(:destroy, requests(:wedge_costumes_for_party)) }
    it { should be_able_to(:cancel, requests(:wedge_costumes_for_party)) }
    it { should_not be_able_to(:adjust_state, requests(:wedge_customes_for_party)) }
  end
end
