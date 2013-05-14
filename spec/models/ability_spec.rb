require 'spec_helper'
require 'cancan/matchers'
#require 'ruby-debug'

describe Ability do
  fixtures :users, :user_profiles, :events, :requests, :request_expenses, :state_transitions
  
  subject { Ability.new(user) }

  context 'when is a requester' do
    let(:user){ users(:luke) }

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
      it{ should_not be_able_to(:cancel, requests(:luke_for_yavin)) }
    end

    context "trying to look into other's requests" do
      it{ should_not be_able_to(:read, requests(:wedge_for_yavin)) }
      it{ should_not be_able_to(:read, requests(:wedge_for_party)) }
      it{ should_not be_able_to(:update, requests(:wedge_for_party)) }
    end

    context "asking for a correct reimbursement" do
      it{ should be_able_to(:create, requests(:luke_for_yavin).build_reimbursement) }
    end

    context "asking for an incorrect reimbursement" do
      let(:user){ users(:wedge) }
      it{ should_not be_able_to(:create, requests(:luke_for_yavin).build_reimbursement) }
      it{ should_not be_able_to(:create, requests(:wedge_for_yavin).build_reimbursement) }
    end

    context "managing a new reimbursement" do
      before(:each) do
        @reimbursement = requests(:luke_for_yavin).create_reimbursement
        @reimbursement.request.expenses.each do |e|
          e.total_amount = e.estimated_amount + 5
        end
      end

      it{ should be_able_to(:submit, @reimbursement) }
      it{ should be_able_to(:update, @reimbursement) }
      it{ should be_able_to(:cancel, @reimbursement) }

      context "and trying to look into other's reimbursements" do
        let(:user){ users(:wedge) }
        it{ should_not be_able_to(:read, @reimbursement) }
        it{ should_not be_able_to(:update, @reimbursement) }
        it{ should_not be_able_to(:submit, @reimbursement) }
        it{ should_not be_able_to(:cancel, @reimbursement) }
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
  end

  context 'when is a TSP member' do
    let(:user){ users(:tspmember) }

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
      it{ should_not be_able_to(:roll_back, @reimbursement) }
      it{ should_not be_able_to(:destroy, @reimbursement) }

      context "already submitted" do
        before(:each) do
          @reimbursement.submit!
        end

        it{ should be_able_to(:read, @reimbursement) }
        it{ should be_able_to(:update, @reimbursement) }
        it{ should be_able_to(:approve, @reimbursement) }
        it{ should be_able_to(:roll_back, @reimbursement) }
        it{ should be_able_to(:cancel, @reimbursement) }
        it{ should_not be_able_to(:destroy, @reimbursement) }
        it{ should_not be_able_to(:authorize, @reimbursement) }

        context "and approved" do
          before(:each) do
            @reimbursement.approve!
          end

          it{ should be_able_to(:read, @reimbursement) }
          it{ should_not be_able_to(:cancel, @reimbursement) }
          it{ should_not be_able_to(:update, @reimbursement) }
          it{ should_not be_able_to(:approve, @reimbursement) }
          it{ should_not be_able_to(:destroy, @reimbursement) }
          it{ should_not be_able_to(:roll_back, @reimbursement) }
          it{ should_not be_able_to(:authorize, @reimbursement) }

          context "and authorized" do
            before(:each) do
              @reimbursement.authorize!
            end

            it{ should be_able_to(:read, @reimbursement) }
            it{ should_not be_able_to(:update, @reimbursement) }
            it{ should_not be_able_to(:approve, @reimbursement) }
            it{ should_not be_able_to(:cancel, @reimbursement) }
            it{ should_not be_able_to(:destroy, @reimbursement) }
            it{ should_not be_able_to(:roll_back, @reimbursement) }
            it{ should_not be_able_to(:authorize, @reimbursement) }
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
  end

  context 'when is an administrative' do
    let(:user){ users(:administrative) }

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
        it{ should_not be_able_to(:authorize, @reimbursement) }

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
          it{ should be_able_to(:authorize, @reimbursement) }

          context "and authorized" do
            before(:each) do
              @reimbursement.authorize!
            end

            it{ should be_able_to(:read, @reimbursement) }
            it{ should_not be_able_to(:update, @reimbursement) }
            it{ should_not be_able_to(:approve, @reimbursement) }
            it{ should_not be_able_to(:cancel, @reimbursement) }
            it{ should_not be_able_to(:destroy, @reimbursement) }
            it{ should_not be_able_to(:roll_back, @reimbursement) }
            it{ should_not be_able_to(:authorize, @reimbursement) }
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
  end
end
