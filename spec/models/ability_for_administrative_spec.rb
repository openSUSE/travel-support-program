require 'spec_helper'
require 'cancan/matchers'
#require 'ruby-debug'

describe "Administrative" do
  fixtures :all

  subject { Ability.new(user) }
  let(:user){ users(:administrative) }

  context 'managing budgets' do
    it{ should_not be_able_to(:create, Budget.new) }
    it{ should_not be_able_to(:read, budgets(:general_budget)) }
    it{ should_not be_able_to(:update, budgets(:general_budget)) }
    it{ should_not be_able_to(:destroy, budgets(:general_budget)) }
  end

  context 'managing events' do
    it{ should be_able_to(:create, Event.new) }
    it{ should_not be_able_to(:update, events(:yavin_hackaton)) }
    it{ should be_able_to(:update, events(:party)) }
    it{ should_not be_able_to(:destroy, events(:yavin_hackaton)) }
    it{ should_not be_able_to(:destroy, events(:party)) }
    it{ should_not be_able_to(:email, events(:yavin_hackaton))}
    it{ should_not be_able_to(:email, events(:party))}
    it{ should_not be_able_to(:email_event, events(:yavin_hackaton))}
    it{ should_not be_able_to(:email_event, events(:party))}
  end

  context 'managing his own requests' do
    it{ should_not be_able_to(:create, TravelSponsorship.new) }
    it{ should be_able_to(:create, TravelSponsorship.new(:event_id => events(:dagobah_camp).id)) }
    it{ should_not be_able_to(:create, TravelSponsorship.new(:event_id => events(:hoth_hackaton).id)) }
    it{ should be_able_to(:read, requests(:administrative_for_party)) }
    it{ should be_able_to(:read, requests(:administrative_for_yavin)) }
    it{ should be_able_to(:update, requests(:administrative_for_party)) }
    it{ should_not be_able_to(:update, requests(:administrative_for_yavin)) }
    it{ should be_able_to(:destroy, requests(:administrative_for_party)) }
    it{ should_not be_able_to(:destroy, requests(:administrative_for_yavin)) }
    it{ should be_able_to(:cancel, requests(:administrative_for_party)) }
    it{ should be_able_to(:cancel, requests(:administrative_for_yavin)) }
    it{ should_not be_able_to(:adjust_state, requests(:administrative_for_yavin)) }
    it{ should_not be_able_to(:adjust_state, requests(:administrative_for_party)) }
  end

  context "managing other's requests" do
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

  context "asking for reimbursement" do
    it{ should be_able_to(:create, requests(:administrative_for_yavin).build_reimbursement) }
    it{ should_not be_able_to(:create, requests(:luke_for_yavin).build_reimbursement) }
  end

  context "managing his own reimbursement" do
    before(:each) do
      @reimbursement = requests(:administrative_for_yavin).create_reimbursement
      @reimbursement.request.expenses.each do |e|
        e.total_amount = e.estimated_amount + 5
      end
      set_acceptance_file @reimbursement
      @reimbursement.create_bank_account(:holder => "C3PO", :bank_name => "Bank",
                                         :format => "iban", :iban => "IBAN", :bic => "BIC")
    end

    it{ should be_able_to(:submit, @reimbursement) }
    it{ should be_able_to(:update, @reimbursement) }
    it{ should be_able_to(:cancel, @reimbursement) }
    it{ should_not be_able_to(:approve, @reimbursement) }
    it{ should_not be_able_to(:process, @reimbursement) }
    it{ should_not be_able_to(:confirm, @reimbursement) }
    it{ should_not be_able_to(:adjust_state, @reimbursement) }

    context "already submitted" do
      before(:each) do
        @reimbursement.submit!
      end

      it{ should be_able_to(:read, @reimbursement) }
      it{ should be_able_to(:roll_back, @reimbursement) }
      it{ should be_able_to(:cancel, @reimbursement) }
      it{ should_not be_able_to(:update, @reimbursement) }
      it{ should_not be_able_to(:approve, @reimbursement) }
      it{ should_not be_able_to(:process, @reimbursement) }
      it{ should_not be_able_to(:confirm, @reimbursement) }
      it{ should_not be_able_to(:destroy, @reimbursement) }
      it{ should_not be_able_to(:adjust_state, @reimbursement) }

      context "and approved" do
        before(:each) do
          @reimbursement.approve!
        end

        it{ should be_able_to(:read, @reimbursement) }
        it{ should be_able_to(:cancel, @reimbursement) }
        it{ should be_able_to(:roll_back, @reimbursement) }
        it{ should_not be_able_to(:update, @reimbursement) }
        it{ should_not be_able_to(:destroy, @reimbursement) }
        it{ should_not be_able_to(:approve, @reimbursement) }
        it{ should_not be_able_to(:process, @reimbursement) }
        it{ should_not be_able_to(:confirm, @reimbursement) }
        it{ should_not be_able_to(:adjust_state, @reimbursement) }

        context "and processed" do
          before(:each) do
            @reimbursement.process!
          end

          it{ should be_able_to(:read, @reimbursement) }
          it{ should_not be_able_to(:update, @reimbursement) }
          it{ should_not be_able_to(:destroy, @reimbursement) }
          it{ should_not be_able_to(:cancel, @reimbursement) }
          it{ should_not be_able_to(:approve, @reimbursement) }
          it{ should_not be_able_to(:roll_back, @reimbursement) }
          it{ should_not be_able_to(:process, @reimbursement) }
          it{ should_not be_able_to(:confirm, @reimbursement) }
          it{ should_not be_able_to(:adjust_state, @reimbursement) }

          context "and payed" do
            before(:each) do
              @reimbursement.confirm!
            end

            it{ should be_able_to(:read, @reimbursement) }
            it{ should_not be_able_to(:update, @reimbursement) }
            it{ should_not be_able_to(:destroy, @reimbursement) }
            it{ should_not be_able_to(:cancel, @reimbursement) }
            it{ should_not be_able_to(:approve, @reimbursement) }
            it{ should_not be_able_to(:roll_back, @reimbursement) }
            it{ should_not be_able_to(:process, @reimbursement) }
            it{ should_not be_able_to(:confirm, @reimbursement) }
            it{ should_not be_able_to(:adjust_state, @reimbursement) }
          end
        end
      end
    end
  end

  context "managing other's reimbursements" do
    before(:each) do
      @reimbursement = requests(:luke_for_yavin).create_reimbursement
      @reimbursement.request.expenses.each do |e|
        e.total_amount = e.estimated_amount + 5
      end
      set_acceptance_file @reimbursement
      @reimbursement.create_bank_account(:holder => "Luke", :bank_name => "Bank",
                                         :format => "iban", :iban => "IBAN", :bic => "BIC")
    end

    it{ should be_able_to(:read, @reimbursement) }
    it{ should_not be_able_to(:update, @reimbursement) }
    it{ should_not be_able_to(:approve, @reimbursement) }
    it{ should_not be_able_to(:roll_back, @reimbursement) }
    it{ should_not be_able_to(:cancel, @reimbursement) }
    it{ should_not be_able_to(:destroy, @reimbursement) }
    it{ should_not be_able_to(:process, @reimbursement) }
    it{ should_not be_able_to(:confirm, @reimbursement) }
    it{ should_not be_able_to(:adjust_state, @reimbursement) }

    context "already submitted" do
      before(:each) do
        @reimbursement.submit!
      end

      it{ should be_able_to(:read, @reimbursement) }
      it{ should_not be_able_to(:update, @reimbursement) }
      it{ should_not be_able_to(:approve, @reimbursement) }
      it{ should be_able_to(:roll_back, @reimbursement) } # Not sure about this one
      it{ should_not be_able_to(:cancel, @reimbursement) }
      it{ should_not be_able_to(:destroy, @reimbursement) }
      it{ should_not be_able_to(:process, @reimbursement) }
      it{ should_not be_able_to(:confirm, @reimbursement) }
      it{ should_not be_able_to(:adjust_state, @reimbursement) }

      context "and approved" do
        before(:each) do
          @reimbursement.approve!
        end

        it{ should be_able_to(:read, @reimbursement) }
        it{ should_not be_able_to(:update, @reimbursement) }
        it{ should_not be_able_to(:approve, @reimbursement) }
        it{ should_not be_able_to(:cancel, @reimbursement) }
        it{ should_not be_able_to(:destroy, @reimbursement) }
        it{ should be_able_to(:roll_back, @reimbursement) }
        it{ should be_able_to(:process, @reimbursement) }
        it{ should_not be_able_to(:confirm, @reimbursement) }
        it{ should_not be_able_to(:adjust_state, @reimbursement) }

        context "and processed" do
          before(:each) do
            @reimbursement.process!
          end

          it{ should be_able_to(:read, @reimbursement) }
          it{ should be_able_to(:confirm, @reimbursement) }
          it{ should_not be_able_to(:update, @reimbursement) }
          it{ should_not be_able_to(:approve, @reimbursement) }
          it{ should_not be_able_to(:cancel, @reimbursement) }
          it{ should_not be_able_to(:destroy, @reimbursement) }
          it{ should_not be_able_to(:roll_back, @reimbursement) }
          it{ should_not be_able_to(:process, @reimbursement) }
          it{ should_not be_able_to(:adjust_state, @reimbursement) }

          context "and payed" do
            before(:each) do
              @reimbursement.confirm!
            end

            it{ should be_able_to(:read, @reimbursement) }
            it{ should_not be_able_to(:update, @reimbursement) }
            it{ should_not be_able_to(:approve, @reimbursement) }
            it{ should_not be_able_to(:cancel, @reimbursement) }
            it{ should_not be_able_to(:destroy, @reimbursement) }
            it{ should_not be_able_to(:roll_back, @reimbursement) }
            it{ should_not be_able_to(:process, @reimbursement) }
            it{ should_not be_able_to(:confirm, @reimbursement) }
            it{ should_not be_able_to(:adjust_state, @reimbursement) }
          end
        end
      end
    end
  end

  context 'adding comments to requests' do
    it{ should be_able_to(:create, requests(:luke_for_party).comments.build) }
    it{ should_not be_able_to(:create, requests(:luke_for_party).comments.build(:private => true)) }
  end

  context 'accessing public comments notes on requests' do
    before(:each) do
      @comment = requests(:luke_for_yavin).comments.create(:body => "whatever")
    end

    it{ should be_able_to(:read, @comment) }
    it{ should_not be_able_to(:destroy, @comment) }
    it{ should_not be_able_to(:update, @comment) }
  end

  context 'accessing private comments notes on requests' do
    before(:each) do
      @comment = requests(:luke_for_yavin).comments.create(:body => "whatever", :private => true)
    end

    it{ should_not be_able_to(:read, @comment) }
    it{ should_not be_able_to(:destroy, @comment) }
    it{ should_not be_able_to(:update, @comment) }
  end

  context 'managing attachments to his own reimbursements' do
    before(:each) do
      @reimbursement = reimbursements(:administrative_for_training_reim)
      set_acceptance_file @reimbursement
    end

    it{ should be_able_to(:read, @reimbursement.attachments.first) }
    it{ should be_able_to(:destroy, @reimbursement.attachments.first) }
    it{ should be_able_to(:update, @reimbursement.attachments.first) }
    it{ should be_able_to(:create, @reimbursement.attachments.build) }

    context 'after submitting it' do
      before(:each) do
        transition(@reimbursement, :submit, users(:administrative))
      end

      it{ should be_able_to(:read, @reimbursement.attachments.first) }
      it{ should_not be_able_to(:destroy, @reimbursement.attachments.first) }
      it{ should_not be_able_to(:update, @reimbursement.attachments.first) }
      it{ should_not be_able_to(:create, @reimbursement.attachments.build) }
    end
  end

  context "accessing attachments in other's reimbursements" do
    before(:each) do
      @reimbursement = reimbursements(:wedge_for_training_reim)
      set_acceptance_file @reimbursement
    end

    it{ should be_able_to(:read, @reimbursement.attachments.first) }
    it{ should_not be_able_to(:destroy, @reimbursement.attachments.first) }
    it{ should_not be_able_to(:update, @reimbursement.attachments.first) }
    it{ should_not be_able_to(:create, @reimbursement.attachments.build) }

    context 'after submitting it' do
      before(:each) do
        transition(@reimbursement, :submit, users(:wedge))
      end

      it{ should be_able_to(:read, @reimbursement.attachments.first) }
      it{ should_not be_able_to(:destroy, @reimbursement.attachments.first) }
      it{ should_not be_able_to(:update, @reimbursement.attachments.first) }
      it{ should_not be_able_to(:create, @reimbursement.attachments.build) }
    end
  end

  context 'managing his own shipments' do
    it{ should_not be_able_to(:create, Shipment.new) }
    it{ should be_able_to(:create, Shipment.new(:event_id => events(:hoth_hackaton).id)) }
    it{ should_not be_able_to(:create, Shipment.new(:event_id => events(:dagobah_camp).id)) }
    it{ should be_able_to(:read, requests(:administrative_customes_for_party)) }
    it{ should be_able_to(:update, requests(:administrative_customes_for_party)) }
    it{ should be_able_to(:destroy, requests(:administrative_customes_for_party)) }
    it{ should be_able_to(:cancel, requests(:administrative_customes_for_party)) }
    it{ should_not be_able_to(:adjust_state, requests(:administrative_customes_for_party)) }
  end

  context "trying to look into other's requests" do
    it{ should_not be_able_to(:read, requests(:wedge_customes_for_party)) }
    it{ should_not be_able_to(:update, requests(:wedge_customes_for_party)) }
    it{ should_not be_able_to(:adjust_state, requests(:wedge_customes_for_party)) }
  end
end
