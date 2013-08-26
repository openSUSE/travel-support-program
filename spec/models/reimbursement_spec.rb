require 'spec_helper'
#require 'ruby-debug'

describe Reimbursement do
  fixtures :all

  context "during initial submission" do
    before(:each) do
      @deliveries = ActionMailer::Base.deliveries.size
      @reimbursement = requests(:luke_for_yavin).create_reimbursement
      @reimbursement.request.expenses.each {|e| e.total_amount = 55 }
      @reimbursement.build_bank_account(:holder => "Owen Lars", :bank_name => "Tatooine Saving Bank",
                                        :format => "iban", :iban => "AT611904300234574444",
                                        :bic => "ABCDEABCDE")
      @reimbursement.save!
      transition(@reimbursement, :submit, users(:luke))
    end

    it "should calculate correctly the authorized amounts" do
      @reimbursement.expenses.reload.map {|i| i.authorized_amount.to_f}.sort.should == [0.0, 50.0, 55.0]
    end

    it "should notify requester and TSP users" do
      ActionMailer::Base.deliveries.size.should == @deliveries + 2
    end

    context "after negotiation" do
      before(:each) do
        @reimbursement.reload
        @reimbursement.request.expenses.each {|e| e.authorized_amount = 10 }
        @reimbursement.save!
        transition(@reimbursement, :roll_back, users(:tspmember))
        @reimbursement.request.expenses.each {|e| e.total_amount = 80 }
        @reimbursement.save!
        transition(@reimbursement, :submit, users(:luke))
      end

      it "should not override the manually set authorized amounts" do
        @reimbursement.expenses.reload.map {|i| i.authorized_amount.to_f}.sort.should == [10.0, 10.0, 10.0]
      end

      it "should notify negotiation steps to requester and TSP" do
        ActionMailer::Base.deliveries.size.should == @deliveries + 6
      end

      context "and approval" do
        before(:each) do
          @deliveries = ActionMailer::Base.deliveries.size
          transition(@reimbursement, :approve, users(:tspmember))
        end

        it "should not override the manually set authorized amounts" do
          @reimbursement.expenses.reload.map {|i| i.authorized_amount.to_f}.sort.should == [10.0, 10.0, 10.0]
        end

        it "should notify approval to requester and TSP" do
          ActionMailer::Base.deliveries.size.should == @deliveries + 2
        end

        it "should notify acceptance to requester, TSP and administrative" do
          ActionMailer::Base.deliveries.size.should == @deliveries + 2
          file = Rails.root.join("spec", "support", "files", "scan001.pdf")
          @reimbursement.acceptance_file = File.open(file, "rb")
          transition(@reimbursement, :accept, users(:tspmember))
          ActionMailer::Base.deliveries.size.should == @deliveries + 5
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
      @reimbursement.build_bank_account(:holder => "Owen Lars", :bank_name => "Tatooine Saving Bank",
                                        :format => "iban", :iban => "AT611904300234574444",
                                        :bic => "ABCDEABCDE")
      @reimbursement.save!
    end

    it "should fail" do
      expect { transition(@reimbursement, :submit, users(:luke)) }.to raise_error(ActiveRecord::RecordNotSaved)
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
