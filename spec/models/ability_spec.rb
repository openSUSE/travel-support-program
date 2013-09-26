require 'spec_helper'
require 'cancan/matchers'
#require 'ruby-debug'

describe Ability do
  fixtures :all

  subject { Ability.new(user) }

  context 'when is a requester' do
    let(:user){ users(:luke) }

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
    end

    context 'managing his own requests' do
      it{ should_not be_able_to(:create, Request.new) }
      it{ should be_able_to(:create, Request.new(:event_id => events(:dagobah_camp).id)) }
      it{ should_not be_able_to(:create, Request.new(:event_id => events(:hoth_hackaton).id)) }
      it{ should be_able_to(:read, requests(:luke_for_party)) }
      it{ should be_able_to(:read, requests(:luke_for_yavin)) }
      it{ should be_able_to(:update, requests(:luke_for_party)) }
      it{ should_not be_able_to(:update, requests(:luke_for_yavin)) }
      it{ should be_able_to(:destroy, requests(:luke_for_party)) }
      it{ should_not be_able_to(:destroy, requests(:luke_for_yavin)) }
      it{ should be_able_to(:cancel, requests(:luke_for_party)) }
      it{ should be_able_to(:cancel, requests(:luke_for_yavin)) }
      it{ should_not be_able_to(:adjust_state, requests(:luke_for_yavin)) }
      it{ should_not be_able_to(:adjust_state, requests(:luke_for_party)) }
    end

    context "trying to look into other's requests" do
      it{ should_not be_able_to(:read, requests(:wedge_for_yavin)) }
      it{ should_not be_able_to(:read, requests(:wedge_for_party)) }
      it{ should_not be_able_to(:update, requests(:wedge_for_party)) }
      it{ should_not be_able_to(:adjust_state, requests(:wedge_for_party)) }
    end

    context "asking for a correct reimbursement" do
      it{ should be_able_to(:create, requests(:luke_for_yavin).build_reimbursement) }
    end

    context "asking for an incorrect reimbursement" do
      let(:user){ users(:wedge) }
      it{ should_not be_able_to(:create, requests(:luke_for_yavin).build_reimbursement) }
      it{ should_not be_able_to(:create, requests(:wedge_for_yavin).build_reimbursement) }
    end

    context "managing a reimbursement" do
      before(:each) do
        @reimbursement = requests(:luke_for_yavin).create_reimbursement
        @reimbursement.request.expenses.each do |e|
          e.total_amount = e.estimated_amount + 5
        end
      end

      it{ should be_able_to(:submit, @reimbursement) }
      it{ should be_able_to(:update, @reimbursement) }
      it{ should be_able_to(:cancel, @reimbursement) }
      it{ should_not be_able_to(:approve, @reimbursement) }
      it{ should_not be_able_to(:accept, @reimbursement) }
      it{ should_not be_able_to(:process, @reimbursement) }
      it{ should_not be_able_to(:confirm, @reimbursement) }
      it{ should_not be_able_to(:reject, @reimbursement) }
      it{ should_not be_able_to(:adjust_state, @reimbursement) }

      context "and trying to look into other's reimbursements" do
        let(:user){ users(:wedge) }
        it{ should_not be_able_to(:read, @reimbursement) }
        it{ should_not be_able_to(:update, @reimbursement) }
        it{ should_not be_able_to(:submit, @reimbursement) }
        it{ should_not be_able_to(:cancel, @reimbursement) }
        it{ should_not be_able_to(:approve, @reimbursement) }
        it{ should_not be_able_to(:accept, @reimbursement) }
        it{ should_not be_able_to(:process, @reimbursement) }
        it{ should_not be_able_to(:confirm, @reimbursement) }
        it{ should_not be_able_to(:reject, @reimbursement) }
        it{ should_not be_able_to(:adjust_state, @reimbursement) }
      end

      context "already submitted" do
        before(:each) do
          @reimbursement.submit!
        end

        it{ should be_able_to(:read, @reimbursement) }
        it{ should be_able_to(:roll_back, @reimbursement) }
        it{ should be_able_to(:cancel, @reimbursement) }
        it{ should_not be_able_to(:update, @reimbursement) }
        it{ should_not be_able_to(:approve, @reimbursement) }
        it{ should_not be_able_to(:accept, @reimbursement) }
        it{ should_not be_able_to(:process, @reimbursement) }
        it{ should_not be_able_to(:confirm, @reimbursement) }
        it{ should_not be_able_to(:destroy, @reimbursement) }
        it{ should_not be_able_to(:reject, @reimbursement) }
        it{ should_not be_able_to(:adjust_state, @reimbursement) }

        context "and approved" do
          before(:each) do
            @reimbursement.approve!
          end

          it{ should be_able_to(:read, @reimbursement) }
          it{ should be_able_to(:cancel, @reimbursement) }
          it{ should be_able_to(:roll_back, @reimbursement) }
          it{ should be_able_to(:accept, @reimbursement) }
          it{ should_not be_able_to(:update, @reimbursement) }
          it{ should_not be_able_to(:destroy, @reimbursement) }
          it{ should_not be_able_to(:approve, @reimbursement) }
          it{ should_not be_able_to(:process, @reimbursement) }
          it{ should_not be_able_to(:confirm, @reimbursement) }
          it{ should_not be_able_to(:reject, @reimbursement) }
          it{ should_not be_able_to(:adjust_state, @reimbursement) }

          context "and accepted" do
            before(:each) do
              file = Rails.root.join("spec", "support", "files", "scan001.pdf")
              @reimbursement.acceptance_file = File.open(file, "rb")
              @reimbursement.accept!
            end

            it{ should be_able_to(:read, @reimbursement) }
            it{ should_not be_able_to(:update, @reimbursement) }
            it{ should_not be_able_to(:destroy, @reimbursement) }
            it{ should be_able_to(:cancel, @reimbursement) }
            it{ should_not be_able_to(:approve, @reimbursement) }
            it{ should_not be_able_to(:roll_back, @reimbursement) }
            it{ should_not be_able_to(:accept, @reimbursement) }
            it{ should_not be_able_to(:process, @reimbursement) }
            it{ should_not be_able_to(:confirm, @reimbursement) }
            it{ should_not be_able_to(:reject, @reimbursement) }
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
              it{ should_not be_able_to(:accept, @reimbursement) }
              it{ should_not be_able_to(:process, @reimbursement) }
              it{ should_not be_able_to(:confirm, @reimbursement) }
              it{ should_not be_able_to(:reject, @reimbursement) }
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
                it{ should_not be_able_to(:accept, @reimbursement) }
                it{ should_not be_able_to(:process, @reimbursement) }
                it{ should_not be_able_to(:confirm, @reimbursement) }
                it{ should_not be_able_to(:reject, @reimbursement) }
                it{ should_not be_able_to(:adjust_state, @reimbursement) }
              end
            end
          end
        end
      end
    end

    context 'adding final notes to his own requests' do
      it{ should_not be_able_to(:create, requests(:luke_for_party).final_notes.build) }
      it{ should be_able_to(:create, requests(:luke_for_yavin).final_notes.build) }
    end

    context 'accessing final notes on his own requests' do
      before(:each) do
        @final_note = requests(:luke_for_yavin).final_notes.create(:body => "whatever")
      end

      it{ should be_able_to(:read, @final_note) }
      it{ should_not be_able_to(:destroy, @final_note) }
      it{ should_not be_able_to(:update, @final_note) }
    end

    context "adding final notes to other's requests" do
      it{ should_not be_able_to(:create, requests(:wedge_for_party).final_notes.build) }
      it{ should_not be_able_to(:create, requests(:wedge_for_yavin).final_notes.build) }
    end

    context "accessing final notes on other's requests" do
      before(:each) do
        @final_note = requests(:wedge_for_yavin).final_notes.create(:body => "whatever")
      end

      it{ should_not be_able_to(:read, @final_note) }
      it{ should_not be_able_to(:destroy, @final_note) }
      it{ should_not be_able_to(:update, @final_note) }
    end

    context 'manage attachments to his own reimbursements' do
      before(:each) do
        @reimbursement = reimbursements(:wedge_for_training_reim)
      end
      let(:user){ users(:wedge) }

      it{ should be_able_to(:read, @reimbursement.attachments.first) }
      it{ should be_able_to(:destroy, @reimbursement.attachments.first) }
      it{ should be_able_to(:update, @reimbursement.attachments.first) }
      it{ should be_able_to(:create, @reimbursement.attachments.build) }

      context 'after submitting it' do
        before(:each) do
          transition(@reimbursement, :submit, users(:wedge))
        end

        it{ should be_able_to(:read, @reimbursement.attachments.first) }
        it{ should_not be_able_to(:destroy, @reimbursement.attachments.first) }
        it{ should_not be_able_to(:update, @reimbursement.attachments.first) }
        it{ should_not be_able_to(:create, @reimbursement.attachments.build) }
      end

      context "and trying to look into other's reimbursements" do
        let(:user){ users(:luke) }
        it{ should_not be_able_to(:read, @reimbursement.attachments.first) }
        it{ should_not be_able_to(:destroy, @reimbursement.attachments.first) }
        it{ should_not be_able_to(:update, @reimbursement.attachments.first) }
        it{ should_not be_able_to(:create, @reimbursement.attachments.build) }
      end
    end
  end

  context 'when is a TSP member' do
    let(:user){ users(:tspmember) }

    context 'managing budgets' do
      it{ should be_able_to(:create, Budget.new) }
      it{ should be_able_to(:read, budgets(:general_budget)) }
      it{ should be_able_to(:update, budgets(:general_budget)) }
      it{ should be_able_to(:destroy, budgets(:general_budget)) }
    end

    context 'managing events' do
      it{ should be_able_to(:create, Event.new) }
      it{ should be_able_to(:update, events(:yavin_hackaton)) }
      it{ should be_able_to(:update, events(:party)) }
      it{ should_not be_able_to(:destroy, events(:yavin_hackaton)) }
      it{ should_not be_able_to(:destroy, events(:party)) }
    end

    context 'managing requests' do
      it{ should_not be_able_to(:create, Request.new) }
      it{ should be_able_to(:read, requests(:wedge_for_party)) }
      it{ should be_able_to(:read, requests(:luke_for_yavin)) }
      it{ should be_able_to(:update, requests(:wedge_for_party)) }
      it{ should be_able_to(:approve, requests(:wedge_for_party)) }
      it{ should be_able_to(:roll_back, requests(:wedge_for_party)) }
      it{ should_not be_able_to(:update, requests(:luke_for_yavin)) }
      it{ should_not be_able_to(:destroy, requests(:luke_for_party)) }
      it{ should_not be_able_to(:destroy, requests(:luke_for_yavin)) }
      it{ should be_able_to(:cancel, requests(:luke_for_party)) }
      it{ should be_able_to(:cancel, requests(:wedge_for_party)) }
      it{ should_not be_able_to(:cancel, requests(:luke_for_yavin)) }
      it{ should_not be_able_to(:adjust_state, requests(:luke_for_yavin)) }
      it{ should_not be_able_to(:adjust_state, requests(:wedge_for_party)) }
    end

    context "managing reimbursements" do
      before(:each) do
        @reimbursement = requests(:luke_for_yavin).create_reimbursement
        @reimbursement.request.expenses.each do |e|
          e.total_amount = e.estimated_amount + 5
        end
      end

      it{ should_not be_able_to(:create, Reimbursement.new) }
      it{ should be_able_to(:read, @reimbursement) }
      it{ should be_able_to(:cancel, @reimbursement) }
      it{ should_not be_able_to(:update, @reimbursement) }
      it{ should_not be_able_to(:approve, @reimbursement) }
      it{ should_not be_able_to(:accept, @reimbursement) }
      it{ should_not be_able_to(:process, @reimbursement) }
      it{ should_not be_able_to(:confirm, @reimbursement) }
      it{ should_not be_able_to(:roll_back, @reimbursement) }
      it{ should_not be_able_to(:destroy, @reimbursement) }
      it{ should_not be_able_to(:reject, @reimbursement) }
      it{ should_not be_able_to(:adjust_state, @reimbursement) }

      context "already submitted" do
        before(:each) do
          @reimbursement.submit!
        end

        it{ should be_able_to(:read, @reimbursement) }
        it{ should be_able_to(:update, @reimbursement) }
        it{ should be_able_to(:approve, @reimbursement) }
        it{ should be_able_to(:roll_back, @reimbursement) }
        it{ should be_able_to(:cancel, @reimbursement) }
        it{ should_not be_able_to(:accept, @reimbursement) }
        it{ should_not be_able_to(:process, @reimbursement) }
        it{ should_not be_able_to(:confirm, @reimbursement) }
        it{ should_not be_able_to(:destroy, @reimbursement) }
        it{ should_not be_able_to(:reject, @reimbursement) }
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
          it{ should_not be_able_to(:accept, @reimbursement) }
          it{ should_not be_able_to(:process, @reimbursement) }
          it{ should_not be_able_to(:confirm, @reimbursement) }
          it{ should_not be_able_to(:reject, @reimbursement) }
          it{ should_not be_able_to(:adjust_state, @reimbursement) }

          context "and accepted" do
            before(:each) do
              file = Rails.root.join("spec", "support", "files", "scan001.pdf")
              @reimbursement.acceptance_file = File.open(file, "rb")
              @reimbursement.accept!
            end

            it{ should be_able_to(:read, @reimbursement) }
            it{ should_not be_able_to(:update, @reimbursement) }
            it{ should_not be_able_to(:destroy, @reimbursement) }
            it{ should_not be_able_to(:cancel, @reimbursement) }
            it{ should_not be_able_to(:approve, @reimbursement) }
            it{ should_not be_able_to(:roll_back, @reimbursement) }
            it{ should_not be_able_to(:accept, @reimbursement) }
            it{ should_not be_able_to(:process, @reimbursement) }
            it{ should_not be_able_to(:confirm, @reimbursement) }
            it{ should_not be_able_to(:reject, @reimbursement) }
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
              it{ should_not be_able_to(:accept, @reimbursement) }
              it{ should_not be_able_to(:process, @reimbursement) }
              it{ should_not be_able_to(:confirm, @reimbursement) }
              it{ should_not be_able_to(:reject, @reimbursement) }
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
                it{ should_not be_able_to(:accept, @reimbursement) }
                it{ should_not be_able_to(:process, @reimbursement) }
                it{ should_not be_able_to(:confirm, @reimbursement) }
                it{ should_not be_able_to(:reject, @reimbursement) }
                it{ should_not be_able_to(:adjust_state, @reimbursement) }
              end
            end
          end
        end
      end
    end

    context 'adding final final notes to requests' do
      it{ should_not be_able_to(:create, requests(:luke_for_party).final_notes.build) }
      it{ should be_able_to(:create, requests(:luke_for_yavin).final_notes.build) }
    end

    context 'accessing final notes on requests' do
      before(:each) do
        @final_note = requests(:luke_for_yavin).final_notes.create(:body => "whatever")
      end

      it{ should be_able_to(:read, @final_note) }
      it{ should_not be_able_to(:destroy, @final_note) }
      it{ should_not be_able_to(:update, @final_note) }
    end

    context 'accessing attachments in a reimbursement' do
      before(:each) do
        @reimbursement = reimbursements(:wedge_for_training_reim)
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
  end

  context 'when is an administrative' do
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
      end

      it{ should_not be_able_to(:create, Reimbursement.new) }
      it{ should be_able_to(:read, @reimbursement) }
      it{ should_not be_able_to(:update, @reimbursement) }
      it{ should_not be_able_to(:approve, @reimbursement) }
      it{ should_not be_able_to(:roll_back, @reimbursement) }
      it{ should_not be_able_to(:cancel, @reimbursement) }
      it{ should_not be_able_to(:destroy, @reimbursement) }
      it{ should_not be_able_to(:accept, @reimbursement) }
      it{ should_not be_able_to(:reject, @reimbursement) }
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
        it{ should_not be_able_to(:roll_back, @reimbursement) }
        it{ should_not be_able_to(:cancel, @reimbursement) }
        it{ should_not be_able_to(:destroy, @reimbursement) }
        it{ should_not be_able_to(:accept, @reimbursement) }
        it{ should_not be_able_to(:reject, @reimbursement) }
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
          it{ should_not be_able_to(:roll_back, @reimbursement) }
          it{ should_not be_able_to(:accept, @reimbursement) }
          it{ should_not be_able_to(:reject, @reimbursement) }
          it{ should_not be_able_to(:process, @reimbursement) }
          it{ should_not be_able_to(:confirm, @reimbursement) }
          it{ should_not be_able_to(:adjust_state, @reimbursement) }

          context "and accepted" do
            before(:each) do
              file = Rails.root.join("spec", "support", "files", "scan001.pdf")
              @reimbursement.acceptance_file = File.open(file, "rb")
              @reimbursement.accept!
            end

            it{ should be_able_to(:read, @reimbursement) }
            it{ should be_able_to(:process, @reimbursement) }
            it{ should be_able_to(:reject, @reimbursement) }
            it{ should_not be_able_to(:update, @reimbursement) }
            it{ should_not be_able_to(:approve, @reimbursement) }
            it{ should_not be_able_to(:cancel, @reimbursement) }
            it{ should_not be_able_to(:destroy, @reimbursement) }
            it{ should_not be_able_to(:roll_back, @reimbursement) }
            it{ should_not be_able_to(:accept, @reimbursement) }
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
              it{ should_not be_able_to(:accept, @reimbursement) }
              it{ should_not be_able_to(:reject, @reimbursement) }
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
                it{ should_not be_able_to(:accept, @reimbursement) }
                it{ should_not be_able_to(:reject, @reimbursement) }
                it{ should_not be_able_to(:process, @reimbursement) }
                it{ should_not be_able_to(:confirm, @reimbursement) }
                it{ should_not be_able_to(:adjust_state, @reimbursement) }
              end
            end
          end
        end
      end
    end

    context 'adding final final notes to requests' do
      it{ should_not be_able_to(:create, requests(:luke_for_party).final_notes.build) }
      it{ should_not be_able_to(:create, requests(:luke_for_yavin).final_notes.build) }
    end

    context 'accessing final notes on requests' do
      before(:each) do
        @final_note = requests(:luke_for_yavin).final_notes.create(:body => "whatever")
      end

      it{ should be_able_to(:read, @final_note) }
      it{ should_not be_able_to(:destroy, @final_note) }
      it{ should_not be_able_to(:update, @final_note) }
    end

    context 'accessing attachments in a reimbursement' do
      before(:each) do
        @reimbursement = reimbursements(:wedge_for_training_reim)
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
  end

  context 'when is an supervisor' do
    let(:user){ users(:supervisor) }

    context 'managing budgets' do
      it{ should be_able_to(:create, Budget.new) }
      it{ should be_able_to(:read, budgets(:general_budget)) }
      it{ should be_able_to(:update, budgets(:general_budget)) }
      it{ should be_able_to(:destroy, budgets(:general_budget)) }
    end

    context 'managing events' do
      it{ should be_able_to(:create, Event.new) }
      it{ should be_able_to(:update, events(:yavin_hackaton)) }
      it{ should be_able_to(:update, events(:party)) }
      it{ should_not be_able_to(:destroy, events(:yavin_hackaton)) }
      it{ should_not be_able_to(:destroy, events(:party)) }
    end

    context 'managing requests' do
      it{ should_not be_able_to(:create, Request.new) }
      it{ should be_able_to(:read, requests(:wedge_for_party)) }
      it{ should be_able_to(:read, requests(:luke_for_yavin)) }
      it{ should be_able_to(:adjust_state, requests(:luke_for_yavin)) }
      it{ should be_able_to(:adjust_state, requests(:wedge_for_party)) }
      it{ should be_able_to(:cancel, requests(:luke_for_party)) }
      it{ should be_able_to(:cancel, requests(:wedge_for_party)) }
      it{ should be_able_to(:cancel, requests(:luke_for_yavin)) }
      it{ should_not be_able_to(:update, requests(:wedge_for_party)) }
      it{ should_not be_able_to(:approve, requests(:wedge_for_party)) }
      it{ should_not be_able_to(:roll_back, requests(:wedge_for_party)) }
      it{ should_not be_able_to(:update, requests(:luke_for_yavin)) }
      it{ should_not be_able_to(:destroy, requests(:luke_for_party)) }
      it{ should_not be_able_to(:destroy, requests(:luke_for_yavin)) }
    end

    context "managing reimbursements" do
      before(:each) do
        @reimbursement = requests(:luke_for_yavin).create_reimbursement
        @reimbursement.request.expenses.each do |e|
          e.total_amount = e.estimated_amount + 5
        end
      end

      it{ should_not be_able_to(:create, Reimbursement.new) }
      it{ should be_able_to(:read, @reimbursement) }
      it{ should be_able_to(:adjust_state, @reimbursement) }
      it{ should be_able_to(:cancel, @reimbursement) }
      it{ should_not be_able_to(:update, @reimbursement) }
      it{ should_not be_able_to(:approve, @reimbursement) }
      it{ should_not be_able_to(:roll_back, @reimbursement) }
      it{ should_not be_able_to(:destroy, @reimbursement) }
      it{ should_not be_able_to(:accept, @reimbursement) }
      it{ should_not be_able_to(:reject, @reimbursement) }
      it{ should_not be_able_to(:process, @reimbursement) }
      it{ should_not be_able_to(:confirm, @reimbursement) }
    end

    context 'adding final final notes to requests' do
      it{ should_not be_able_to(:create, requests(:luke_for_party).final_notes.build) }
      it{ should be_able_to(:create, requests(:luke_for_yavin).final_notes.build) }
    end

    context 'accessing final notes on requests' do
      before(:each) do
        @final_note = requests(:luke_for_yavin).final_notes.create(:body => "whatever")
      end

      it{ should be_able_to(:read, @final_note) }
      it{ should_not be_able_to(:destroy, @final_note) }
      it{ should_not be_able_to(:update, @final_note) }
    end

    context 'accessing attachments in a reimbursement' do
      before(:each) do
        @reimbursement = reimbursements(:wedge_for_training_reim)
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
  end
end
