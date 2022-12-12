# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

describe CommentMailer do
  fixtures :all

  context 'adding a public comment to a request' do
    before(:each) do
      @user = users(:wedge)
      @request = requests(:wedge_for_yavin)
      @body = 'Luke always get all the money.'
      @mcount = ActionMailer::Base.deliveries.size
      comment = @request.comments.build(body: @body)
      comment.user = @user
      comment.save!
      @mails = ActionMailer::Base.deliveries[-3..-1]
    end

    it 'should mail requester, tsp and assistant' do
      ActionMailer::Base.deliveries.size.should == @mcount + 3
      @mails.map(&:to).flatten.should include @request.user.email
    end

    it 'should include user in the mail body' do
      @mails.first.body.encoded.should include @user.nickname
    end

    it 'should include message in the mail body' do
      @mails.last.body.encoded.should include @body
    end

    it 'should not include private note' do
      @mails.last.body.encoded.should_not include TravelSponsorship.private_comment_hint
    end

    it 'should include request url in the mail body' do
      @mails.first.body.encoded.should match "http.+/travel_sponsorships/#{@request.id}"
    end
  end

  context 'adding a private comment to a request' do
    before(:each) do
      @user = users(:tspmember)
      @request = requests(:wedge_for_yavin)
      @body = "I don't like this person."
      @mcount = ActionMailer::Base.deliveries.size
      comment = @request.comments.build(body: @body, private: true)
      comment.user = @user
      comment.save!
      @mails = ActionMailer::Base.deliveries[-2..-1]
    end

    it 'should include private note' do
      @mails.first.body.encoded.should include TravelSponsorship.private_comment_hint
    end

    it 'should mail tsp and assistant, but not requester' do
      ActionMailer::Base.deliveries.size.should == @mcount + 2
      @mails.map(&:to).flatten.should_not include @request.user.email
    end
  end

  context 'supervisor adding comment to a reimbursement' do
    before(:each) do
      @user = users(:supervisor)
      @reimbursement = reimbursements(:wedge_for_training_reim)
      @mcount = ActionMailer::Base.deliveries.size
      comment = @reimbursement.comments.build(body: 'Blah')
      comment.user = @user
      comment.save!
    end

    it 'should mail tsp, assistant, requester and supervisor (author)' do
      ActionMailer::Base.deliveries.size.should == @mcount + 4
    end

    context 'and other people adding more public comments' do
      before(:each) do
        @body = 'Could you please be more precise?'
        @wedge = users(:wedge)
        comment = @reimbursement.comments.build(body: @body)
        comment.user = @wedge
        comment.save!
        @mails = ActionMailer::Base.deliveries[-4..-1]
      end

      it 'should mail tsp, assistant, requester and supervisor (due to their previous comment)' do
        ActionMailer::Base.deliveries.size.should == @mcount + 8
        @mails.map(&:to).flatten.should include @user.email
      end

      context 'and adding a subsequent private comment' do
        before(:each) do
          @body = "I still don't like this person."
          comment = @reimbursement.comments.build(body: @body, private: true)
          comment.user = users(:tspmember)
          comment.save!
          @mails = ActionMailer::Base.deliveries[-3..-1]
        end

        it 'should mail tsp, assistant and supervisor but not requester' do
          ActionMailer::Base.deliveries.size.should == @mcount + 8 + 3
          @mails.map(&:to).flatten.should include @user.email
          @mails.map(&:to).flatten.should_not include @wedge.email
        end
      end
    end
  end

  context 'adding a public comment to a shipment' do
    before(:each) do
      @user = users(:wedge)
      @material = users(:material)
      @shipment = requests(:wedge_costumes_for_party)
      @body = "I'm planning to use one of the costumes to dress Chewbacca up."
      @mcount = ActionMailer::Base.deliveries.size
      comment = @shipment.comments.build(body: @body)
      comment.user = @user
      comment.save!
      @mails = ActionMailer::Base.deliveries[-2..-1]
    end

    it 'should mail requester and material manager' do
      ActionMailer::Base.deliveries.size.should == @mcount + 2
      @mails.map(&:to).flatten.should include @user.email
      @mails.map(&:to).flatten.should include @material.email
    end

    it 'should not include private note' do
      @mails.last.body.encoded.should_not include Shipment.private_comment_hint
    end

    context 'adding a private comment to a shipment' do
      before(:each) do
        @body = 'This person is stupid.'
        comment = @shipment.comments.build(body: @body, private: true)
        comment.user = @material
        comment.save!
        @mail = ActionMailer::Base.deliveries.last
      end

      it 'should only mail material managers' do
        ActionMailer::Base.deliveries.size.should == @mcount + 3
        @mail.to.should_not include @user.email
        @mail.to.should include @material.email
      end

      it 'should include private note' do
        @mail.body.encoded.should include Shipment.private_comment_hint
      end
    end
  end
end
