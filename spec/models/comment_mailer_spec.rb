require 'spec_helper'
#require 'ruby-debug'

describe CommentMailer do
  fixtures :all

  context "adding a public comment to a request" do
    before(:each) do
      @user = users(:wedge)
      @request = requests(:wedge_for_yavin)
      @body = "Luke always get all the money."
      @mcount = ActionMailer::Base.deliveries.size
      comment = @request.comments.build(:body => @body)
      comment.user = @user
      comment.save!
      @mails = ActionMailer::Base.deliveries[-3..-1]
    end

    it "should mail requester, tsp and assistant" do
      ActionMailer::Base.deliveries.size.should == @mcount + 3
      @mails.map(&:to).flatten.should include @request.user.email
    end

    it "should include user in the mail body" do
      @mails.first.body.encoded.should include @user.nickname
    end

    it "should include message in the mail body" do
      @mails.last.body.encoded.should include @body
    end

    it "should not include private note" do
      @mails.last.body.encoded.should_not include Comment.private_hint
    end

    it "should include request url in the mail body" do
      @mails.first.body.encoded.should match "http.+/requests/#{@request.id}"
    end
  end

  context "adding a private comment to a request" do
    before(:each) do
      @user = users(:tspmember)
      @request = requests(:wedge_for_yavin)
      @body = "I don't like this guy."
      @mcount = ActionMailer::Base.deliveries.size
      comment = @request.comments.build(:body => @body, :private => true)
      comment.user = @user
      comment.save!
      @mails = ActionMailer::Base.deliveries[-2..-1]
    end

    it "should include private note" do
      @mails.first.body.encoded.should include Comment.private_hint
    end

    it "should mail tsp and assistant, but not requester" do
      ActionMailer::Base.deliveries.size.should == @mcount + 2
      @mails.map(&:to).flatten.should_not include @request.user.email
    end
  end

  context "supervisor adding comment to a reimbursement" do
    before(:each) do
      @user = users(:supervisor)
      @reimbursement = reimbursements(:wedge_for_training_reim)
      @mcount = ActionMailer::Base.deliveries.size
      comment = @reimbursement.comments.build(:body => "Blah")
      comment.user = @user
      comment.save!
    end

    it "should mail tsp, assistant, requester and supervisor (author)" do
      ActionMailer::Base.deliveries.size.should == @mcount + 4
    end

    context "and other people adding more comments" do
      before(:each) do
        @body = "Could you please be more precise?"
        comment = @reimbursement.comments.build(:body => @body)
        comment.user = users(:wedge)
        comment.save!
        @mails = ActionMailer::Base.deliveries[-4..-1]
      end

      it "should mail tsp, assistant, requester and supervisor (due to his previous comment)" do
        ActionMailer::Base.deliveries.size.should == @mcount + 8
        @mails.map(&:to).flatten.should include @user.email
      end
    end
  end
end
