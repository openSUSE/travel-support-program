require "spec_helper"

describe Event, type: :mailer do
  describe "Event Info" do
    email = {to: 'luke.skywalker@rebel-alliance.org', subject: 'Event email test', body: 'This is a mail to test the Event Mailer'}
    let(:mail) { EventMailer.event_info(email[:to],email).deliver }

    it "renders the headers" do
      expect(mail.subject).to eq("Event email test")
      expect(mail.to).to eq(["luke.skywalker@rebel-alliance.org"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("This is a mail to test the Event Mailer")
    end
  end

end
