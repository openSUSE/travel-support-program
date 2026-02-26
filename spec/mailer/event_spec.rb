# frozen_string_literal: true

require 'spec_helper'

describe Event, type: :mailer do
  fixtures :all
  describe 'Event Info' do
    let(:mail) { EventMailer.event_info(event_emails(:party_info).to, event_emails(:party_info)).deliver_now }

    it 'sets the correct subject' do
      expect(mail.subject).to eq('Testing mail')
    end

    it 'sets the correct recipient' do
      expect(mail.to).to eq(['test@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('This is a test mail')
    end
  end
end
