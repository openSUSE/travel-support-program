require 'spec_helper'

describe Event, type: :mailer do
  fixtures :all
  describe 'Event Info' do
    let(:mail) { EventMailer.event_info(event_emails(:party_info).to, event_emails(:party_info)).deliver }

    it 'renders the headers' do
      expect(mail.subject).to eq('Testing mail')
      expect(mail.to).to eq(['test@example.com'])
    end

    it 'renders the body' do
      expect(mail.body.encoded).to match('This is a test mail')
    end
  end
end
