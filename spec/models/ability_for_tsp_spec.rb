# frozen_string_literal: true

require 'spec_helper'
require 'cancan/matchers'
# require 'ruby-debug'

describe 'TSP' do
  fixtures :all

  subject { Ability.new(user) }

  let(:user) { users(:tspmember) }

  context 'when managing budgets' do
    it { is_expected.to be_able_to(:create, Budget.new) }
    it { is_expected.to be_able_to(:read, budgets(:general_budget)) }
    it { is_expected.to be_able_to(:update, budgets(:general_budget)) }
    it { is_expected.to be_able_to(:destroy, budgets(:general_budget)) }
  end

  context 'when managing events' do
    it { is_expected.to be_able_to(:create, Event.new) }
    it { is_expected.to be_able_to(:update, events(:yavin_hackaton)) }
    it { is_expected.to be_able_to(:update, events(:party)) }
    it { is_expected.not_to be_able_to(:destroy, events(:yavin_hackaton)) }
    it { is_expected.not_to be_able_to(:destroy, events(:party)) }
  end

  context 'when managing event emails' do
    it { is_expected.to be_able_to(:create, EventEmail.new) }
    it { is_expected.to be_able_to(:read, event_emails(:party_info)) }
  end

  context 'when managing event organizers' do
    it { is_expected.to be_able_to(:create, EventOrganizer.new) }
    it { is_expected.to be_able_to(:read, event_organizers(:event_org_luke)) }
  end

  context 'when managing their own requests' do
    it { is_expected.not_to be_able_to(:create, TravelSponsorship.new) }
    it { is_expected.to be_able_to(:create, TravelSponsorship.new(event_id: events(:dagobah_camp).id)) }
    it { is_expected.not_to be_able_to(:create, TravelSponsorship.new(event_id: events(:hoth_hackaton).id)) }
    it { is_expected.to be_able_to(:read, requests(:tspmember_for_party)) }
    it { is_expected.to be_able_to(:read, requests(:tspmember_for_yavin)) }
    it { is_expected.to be_able_to(:update, requests(:tspmember_for_party)) }
    it { is_expected.not_to be_able_to(:update, requests(:tspmember_for_yavin)) }
    it { is_expected.to be_able_to(:destroy, requests(:tspmember_for_party)) }
    it { is_expected.not_to be_able_to(:destroy, requests(:tspmember_for_yavin)) }
    it { is_expected.to be_able_to(:cancel, requests(:tspmember_for_party)) }
    it { is_expected.to be_able_to(:cancel, requests(:tspmember_for_yavin)) }
    it { is_expected.not_to be_able_to(:adjust_state, requests(:tspmember_for_yavin)) }
    it { is_expected.not_to be_able_to(:adjust_state, requests(:tspmember_for_party)) }
  end

  context "when managing other's requests" do
    it { is_expected.to be_able_to(:read, requests(:wedge_for_party)) }
    it { is_expected.to be_able_to(:read, requests(:luke_for_yavin)) }
    it { is_expected.not_to be_able_to(:update, requests(:wedge_for_party)) }
    it { is_expected.to be_able_to(:approve, requests(:wedge_for_party)) }
    it { is_expected.to be_able_to(:roll_back, requests(:wedge_for_party)) }
    it { is_expected.not_to be_able_to(:update, requests(:luke_for_yavin)) }
    it { is_expected.not_to be_able_to(:destroy, requests(:luke_for_party)) }
    it { is_expected.not_to be_able_to(:destroy, requests(:luke_for_yavin)) }
    it { is_expected.to be_able_to(:cancel, requests(:luke_for_party)) }
    it { is_expected.to be_able_to(:cancel, requests(:wedge_for_party)) }
    it { is_expected.not_to be_able_to(:cancel, requests(:luke_for_yavin)) }
    it { is_expected.not_to be_able_to(:adjust_state, requests(:luke_for_yavin)) }
    it { is_expected.not_to be_able_to(:adjust_state, requests(:wedge_for_party)) }
  end

  context 'when asking for reimbursement' do
    it { is_expected.to be_able_to(:create, requests(:tspmember_for_yavin).build_reimbursement) }
    it { is_expected.not_to be_able_to(:create, requests(:assistant_for_yavin).build_reimbursement) }
    it { is_expected.not_to be_able_to(:create, requests(:luke_for_yavin).build_reimbursement) }
  end

  context 'when managing their own reimbursement' do
    let(:reimbursement) { requests(:tspmember_for_yavin).create_reimbursement }

    before do
      reimbursement.request.expenses.each do |e|
        e.total_amount = e.estimated_amount + 5
      end
      set_acceptance_file reimbursement
      reimbursement.create_bank_account(holder: 'The TSP member', bank_name: 'Bank',
                                        format: 'iban', iban: 'IBAN', bic: 'BIC')
    end

    it { is_expected.to be_able_to(:submit, reimbursement) }
    it { is_expected.to be_able_to(:update, reimbursement) }
    it { is_expected.to be_able_to(:cancel, reimbursement) }
    it { is_expected.not_to be_able_to(:approve, reimbursement) }
    it { is_expected.not_to be_able_to(:process, reimbursement) }
    it { is_expected.not_to be_able_to(:confirm, reimbursement) }
    it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }

    context 'when already submitted' do
      before do
        reimbursement.submit!
      end

      it { is_expected.to be_able_to(:read, reimbursement) }
      it { is_expected.to be_able_to(:roll_back, reimbursement) }
      it { is_expected.to be_able_to(:cancel, reimbursement) }
      it { is_expected.not_to be_able_to(:update, reimbursement) }
      it { is_expected.not_to be_able_to(:approve, reimbursement) }
      it { is_expected.not_to be_able_to(:process, reimbursement) }
      it { is_expected.not_to be_able_to(:confirm, reimbursement) }
      it { is_expected.not_to be_able_to(:destroy, reimbursement) }
      it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }

      context 'when approved' do
        before do
          reimbursement.approve!
        end

        it { is_expected.to be_able_to(:read, reimbursement) }
        it { is_expected.to be_able_to(:cancel, reimbursement) }
        it { is_expected.to be_able_to(:roll_back, reimbursement) }
        it { is_expected.not_to be_able_to(:update, reimbursement) }
        it { is_expected.not_to be_able_to(:destroy, reimbursement) }
        it { is_expected.not_to be_able_to(:approve, reimbursement) }
        it { is_expected.not_to be_able_to(:process, reimbursement) }
        it { is_expected.not_to be_able_to(:confirm, reimbursement) }
        it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }

        context 'when processed' do
          before do
            reimbursement.process!
          end

          it { is_expected.to be_able_to(:read, reimbursement) }
          it { is_expected.not_to be_able_to(:update, reimbursement) }
          it { is_expected.not_to be_able_to(:destroy, reimbursement) }
          it { is_expected.not_to be_able_to(:cancel, reimbursement) }
          it { is_expected.not_to be_able_to(:approve, reimbursement) }
          it { is_expected.not_to be_able_to(:roll_back, reimbursement) }
          it { is_expected.not_to be_able_to(:process, reimbursement) }
          it { is_expected.not_to be_able_to(:confirm, reimbursement) }
          it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }

          context 'when payed' do
            before do
              reimbursement.confirm!
            end

            it { is_expected.to be_able_to(:read, reimbursement) }
            it { is_expected.not_to be_able_to(:update, reimbursement) }
            it { is_expected.not_to be_able_to(:destroy, reimbursement) }
            it { is_expected.not_to be_able_to(:cancel, reimbursement) }
            it { is_expected.not_to be_able_to(:approve, reimbursement) }
            it { is_expected.not_to be_able_to(:roll_back, reimbursement) }
            it { is_expected.not_to be_able_to(:process, reimbursement) }
            it { is_expected.not_to be_able_to(:confirm, reimbursement) }
            it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }
          end
        end
      end
    end
  end

  context "when managing other's reimbursements" do
    let(:reimbursement) { requests(:luke_for_yavin).create_reimbursement }

    before do
      reimbursement.request.expenses.each do |e|
        e.total_amount = e.estimated_amount + 5
      end
      set_acceptance_file reimbursement
      reimbursement.create_bank_account(holder: 'Luke', bank_name: 'Bank',
                                        format: 'iban', iban: 'IBAN', bic: 'BIC')
    end

    it { is_expected.to be_able_to(:read, reimbursement) }
    it { is_expected.to be_able_to(:cancel, reimbursement) }
    it { is_expected.not_to be_able_to(:update, reimbursement) }
    it { is_expected.not_to be_able_to(:approve, reimbursement) }
    it { is_expected.not_to be_able_to(:process, reimbursement) }
    it { is_expected.not_to be_able_to(:confirm, reimbursement) }
    it { is_expected.not_to be_able_to(:roll_back, reimbursement) }
    it { is_expected.not_to be_able_to(:destroy, reimbursement) }
    it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }

    context 'when already submitted' do
      before do
        reimbursement.submit!
      end

      it { is_expected.to be_able_to(:read, reimbursement) }
      it { is_expected.not_to be_able_to(:update, reimbursement) }
      it { is_expected.to be_able_to(:approve, reimbursement) }
      it { is_expected.to be_able_to(:roll_back, reimbursement) }
      it { is_expected.to be_able_to(:cancel, reimbursement) }
      it { is_expected.not_to be_able_to(:process, reimbursement) }
      it { is_expected.not_to be_able_to(:confirm, reimbursement) }
      it { is_expected.not_to be_able_to(:destroy, reimbursement) }
      it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }

      context 'when approved' do
        before do
          reimbursement.approve!
        end

        it { is_expected.to be_able_to(:read, reimbursement) }
        it { is_expected.to be_able_to(:cancel, reimbursement) }
        it { is_expected.to be_able_to(:roll_back, reimbursement) }
        it { is_expected.not_to be_able_to(:update, reimbursement) }
        it { is_expected.not_to be_able_to(:destroy, reimbursement) }
        it { is_expected.not_to be_able_to(:approve, reimbursement) }
        it { is_expected.not_to be_able_to(:process, reimbursement) }
        it { is_expected.not_to be_able_to(:confirm, reimbursement) }
        it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }

        context 'when processed' do
          before do
            reimbursement.process!
          end

          it { is_expected.to be_able_to(:read, reimbursement) }
          it { is_expected.not_to be_able_to(:update, reimbursement) }
          it { is_expected.not_to be_able_to(:destroy, reimbursement) }
          it { is_expected.not_to be_able_to(:cancel, reimbursement) }
          it { is_expected.not_to be_able_to(:approve, reimbursement) }
          it { is_expected.not_to be_able_to(:roll_back, reimbursement) }
          it { is_expected.not_to be_able_to(:process, reimbursement) }
          it { is_expected.not_to be_able_to(:confirm, reimbursement) }
          it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }

          context 'when payed' do
            before do
              reimbursement.confirm!
            end

            it { is_expected.to be_able_to(:read, reimbursement) }
            it { is_expected.not_to be_able_to(:update, reimbursement) }
            it { is_expected.not_to be_able_to(:destroy, reimbursement) }
            it { is_expected.not_to be_able_to(:cancel, reimbursement) }
            it { is_expected.not_to be_able_to(:approve, reimbursement) }
            it { is_expected.not_to be_able_to(:roll_back, reimbursement) }
            it { is_expected.not_to be_able_to(:process, reimbursement) }
            it { is_expected.not_to be_able_to(:confirm, reimbursement) }
            it { is_expected.not_to be_able_to(:adjust_state, reimbursement) }
          end
        end
      end
    end
  end

  context 'when adding comments to requests' do
    it { is_expected.to be_able_to(:create, requests(:luke_for_yavin).comments.build) }
    it { is_expected.to be_able_to(:create, requests(:luke_for_yavin).comments.build(private: true)) }
  end

  context 'when accessing public comments on requests' do
    let(:comment) { requests(:luke_for_yavin).comments.create(body: 'whatever') }

    it { is_expected.to be_able_to(:read, comment) }
    it { is_expected.not_to be_able_to(:destroy, comment) }
    it { is_expected.not_to be_able_to(:update, comment) }
  end

  context 'when accessing private comments on requests' do
    let(:comment) { requests(:luke_for_yavin).comments.create(body: 'whatever', private: true) }

    it { is_expected.to be_able_to(:read, comment) }
    it { is_expected.not_to be_able_to(:destroy, comment) }
    it { is_expected.not_to be_able_to(:update, comment) }
  end

  context 'when accessing attachments in a reimbursement' do
    let(:reimbursement) { reimbursements(:wedge_for_training_reim) }

    before do
      set_acceptance_file reimbursement
    end

    it { is_expected.to be_able_to(:read, reimbursement.attachments.first) }
    it { is_expected.not_to be_able_to(:destroy, reimbursement.attachments.first) }
    it { is_expected.not_to be_able_to(:update, reimbursement.attachments.first) }
    it { is_expected.not_to be_able_to(:create, reimbursement.attachments.build) }

    context 'when submitting it' do
      before do
        transition(reimbursement, :submit, users(:wedge))
      end

      it { is_expected.to be_able_to(:read, reimbursement.attachments.first) }
      it { is_expected.not_to be_able_to(:destroy, reimbursement.attachments.first) }
      it { is_expected.not_to be_able_to(:update, reimbursement.attachments.first) }
      it { is_expected.not_to be_able_to(:create, reimbursement.attachments.build) }
    end
  end

  context 'when accessing shipments' do
    it { is_expected.not_to be_able_to(:create, Shipment.new) }
    it { is_expected.not_to be_able_to(:read, requests(:wedge_costumes_for_party)) }
    it { is_expected.not_to be_able_to(:update, requests(:wedge_costumes_for_party)) }
    it { is_expected.not_to be_able_to(:destroy, requests(:wedge_costumes_for_party)) }
  end

  context 'when adding comments to shipments' do
    it { is_expected.not_to be_able_to(:create, requests(:luke_costumes_for_party).comments.build) }
    it { is_expected.not_to be_able_to(:create, requests(:luke_costumes_for_party).comments.build(private: true)) }
  end

  context 'when accessing public comments on shipments' do
    let(:comment) { requests(:luke_costumes_for_party).comments.create(body: 'whatever') }

    it { is_expected.not_to be_able_to(:read, comment) }
    it { is_expected.not_to be_able_to(:destroy, comment) }
    it { is_expected.not_to be_able_to(:update, comment) }
  end

  context 'when accessing private comments on shipments' do
    let(:comment) { requests(:luke_costumes_for_party).comments.create(body: 'whatever', private: true) }

    it { is_expected.not_to be_able_to(:read, comment) }
    it { is_expected.not_to be_able_to(:destroy, comment) }
    it { is_expected.not_to be_able_to(:update, comment) }
  end
end
