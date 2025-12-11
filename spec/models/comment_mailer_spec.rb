# frozen_string_literal: true

require 'spec_helper'
# require 'ruby-debug'

describe CommentMailer do
  let!(:mcount) { ActionMailer::Base.deliveries.size }

  fixtures :all

  context 'when adding a public comment to a request' do
    let(:user) { users(:wedge) }
    let(:request) { requests(:wedge_for_yavin) }
    let(:body) { 'Luke always get all the money.' }
    let(:mails) { ActionMailer::Base.deliveries[-3..-1] }

    before do
      comment = request.comments.build(body: body)
      comment.user = user
      comment.save!
    end

    it 'mails requester, tsp and assistant' do
      ActionMailer::Base.deliveries.size.should == mcount + 3
      mails.map(&:to).flatten.should include request.user.email
    end

    it 'includes user in the mail body' do
      mails.first.body.encoded.should include user.nickname
    end

    it 'includes message in the mail body' do
      mails.last.body.encoded.should include body
    end

    it 'does not include private note' do
      mails.last.body.encoded.should_not include TravelSponsorship.private_comment_hint
    end

    it 'includes request url in the mail body' do
      mails.first.body.encoded.should match "http.+/travel_sponsorships/#{request.id}"
    end
  end

  context 'when adding a private comment to a request' do
    let(:user) { users(:tspmember) }
    let(:request) { requests(:wedge_for_yavin) }
    let(:body) { "I don't like this person." }
    let(:mails) { ActionMailer::Base.deliveries[-2..-1] }

    before do
      comment = request.comments.build(body: body, private: true)
      comment.user = user
      comment.save!
    end

    it 'includes private note' do
      mails.first.body.encoded.should include TravelSponsorship.private_comment_hint
    end

    it 'mails tsp and assistant, but not requester' do
      ActionMailer::Base.deliveries.size.should == mcount + 2
      mails.map(&:to).flatten.should_not include request.user.email
    end
  end

  context 'with supervisor adding comment to a reimbursement' do
    let(:user) { users(:supervisor) }
    let(:reimbursement) { reimbursements(:wedge_for_training_reim) }

    before do
      comment = reimbursement.comments.build(body: 'Blah')
      comment.user = user
      comment.save!
    end

    it 'mails tsp, assistant, requester and supervisor (author)' do
      ActionMailer::Base.deliveries.size.should == mcount + 4
    end

    context 'with other people adding more public comments' do
      let(:wedge) { users(:wedge) }
      let(:body) { 'Could you please be more precise?' }
      let(:mails) { ActionMailer::Base.deliveries[-4..-1] }

      before do
        comment = reimbursement.comments.build(body: body)
        comment.user = wedge
        comment.save!
      end

      it 'mails tsp, assistant, requester and supervisor (due to their previous comment)' do
        ActionMailer::Base.deliveries.size.should == mcount + 8
        mails.map(&:to).flatten.should include user.email
      end

      context 'when adding a subsequent private comment' do
        let(:body) { "I still don't like this person." }
        let(:mails) { ActionMailer::Base.deliveries[-3..-1] }

        before do
          comment = reimbursement.comments.build(body: body, private: true)
          comment.user = users(:tspmember)
          comment.save!
        end

        it 'with mails tsp, assistant and supervisor but not requester' do
          ActionMailer::Base.deliveries.size.should == mcount + 8 + 3
          mails.map(&:to).flatten.should include user.email
          mails.map(&:to).flatten.should_not include wedge.email
        end
      end
    end
  end

  context 'when adding a public comment to a shipment' do
    let(:user) { users(:wedge) }
    let(:material) { users(:material) }
    let(:shipment) { requests(:wedge_costumes_for_party) }
    let(:body) { "I'm planning to use one of the costumes to dress Chewbacca up." }
    let(:mails) { ActionMailer::Base.deliveries[-2..-1] }

    before do
      comment = shipment.comments.build(body: body)
      comment.user = user
      comment.save!
    end

    it 'mails requester and material manager' do
      ActionMailer::Base.deliveries.size.should == mcount + 2
      mails.map(&:to).flatten.should include user.email
      mails.map(&:to).flatten.should include material.email
    end

    it 'does not include private note' do
      mails.last.body.encoded.should_not include Shipment.private_comment_hint
    end

    context 'when adding a private comment to a shipment' do
      let(:body) { 'This person is stupid.' }
      let(:mail) { ActionMailer::Base.deliveries.last }

      before do
        comment = shipment.comments.build(body: body, private: true)
        comment.user = material
        comment.save!
      end

      it 'onlies mail material managers' do
        ActionMailer::Base.deliveries.size.should == mcount + 3
        mail.to.should_not include user.email
        mail.to.should include material.email
      end

      it 'includes private note' do
        mail.body.encoded.should include Shipment.private_comment_hint
      end
    end
  end
end
