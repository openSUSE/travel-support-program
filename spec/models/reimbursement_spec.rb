require 'spec_helper'
#require 'ruby-debug'

describe Reimbursement do
  fixtures :all

  context "during initial submission" do
    before(:each) do
      @deliveries = ActionMailer::Base.deliveries.size
      @reimbursement = requests(:luke_for_yavin).create_reimbursement
      @reimbursement.request.expenses.each {|e| e.total_amount = 55 }
      set_acceptance_file @reimbursement
      @reimbursement.build_bank_account(:holder => "Owen Lars", :bank_name => "Tatooine Saving Bank",
                                        :format => "iban", :iban => "AT611904300234574444",
                                        :bic => "ABCDEABCDE")
      @reimbursement.save!
      transition(@reimbursement, :submit, users(:luke))
    end

    it "should calculate correctly the authorized amounts" do
      @reimbursement.expenses.reload.map {|i| i.authorized_amount.to_f}.sort.should == [0.0, 50.0, 55.0]
    end

    it "should notify requester, TSP users and assistants" do
      ActionMailer::Base.deliveries.size.should == @deliveries + 3
    end

    context "after negotiation" do
      before(:each) do
        @reimbursement.reload
        transition(@reimbursement, :roll_back, users(:tspmember))
        @reimbursement.request.expenses.each {|e| e.total_amount = 80 }
        @reimbursement.save!
        transition(@reimbursement, :submit, users(:luke))
      end

      #it "should not override the manually set authorized amounts" do
      #  @reimbursement.expenses.reload.map {|i| i.authorized_amount.to_f}.sort.should == [10.0, 10.0, 10.0]
      #end

      it "should notify negotiation steps to requester, TSP and assistants" do
        ActionMailer::Base.deliveries.size.should == @deliveries + 9
      end

      context "and approval" do
        before(:each) do
          @deliveries = ActionMailer::Base.deliveries.size
          transition(@reimbursement, :approve, users(:tspmember))
        end

        #it "should not override the manually set authorized amounts" do
        #  @reimbursement.expenses.reload.map {|i| i.authorized_amount.to_f}.sort.should == [10.0, 10.0, 10.0]
        #end

        it "should notify approval to requester, TSP, assistants and administrative" do
          ActionMailer::Base.deliveries.size.should == @deliveries + 4
        end
      end
    end
  end

  context "submitting with incomplete profile" do
    before(:each) do
      @user = users(:luke)
      @user.profile.location = nil
      @user.profile.save!
      @reimbursement = requests(:luke_for_yavin).create_reimbursement
      @reimbursement.request.expenses.each {|e| e.total_amount = 55 }
      set_acceptance_file @reimbursement
      @reimbursement.build_bank_account(:holder => "Owen Lars", :bank_name => "Tatooine Saving Bank",
                                        :format => "iban", :iban => "AT611904300234574444",
                                        :bic => "ABCDEABCDE")
      @reimbursement.save!
    end

    it "should fail" do
      expect { transition(@reimbursement, :submit, users(:luke)) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    context "and fixing the profile" do
      before(:each) do
        @user.profile.update_attribute :location, "Nomad"
      end

      it "should success" do
        transition(@reimbursement, :submit, users(:luke))
        @reimbursement.submitted?.should be_true
      end
    end
  end
end
