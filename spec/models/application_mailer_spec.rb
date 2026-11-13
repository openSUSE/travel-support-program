# frozen_string_literal: true

require 'spec_helper'

describe ApplicationMailer do
  fixtures :all

  it 'delivers asynchronous notifications through a queued worker', :aggregate_failures do
    recipient = users(:wedge)
    request = requests(:wedge_for_training)
    previous_setting = Rails.configuration.site['async_emails']
    Rails.configuration.site['async_emails'] = true

    expect do
      HasStateMailer.notify_to(recipient, :state, request)
    end.to change(Delayed::Job, :count).by(1)

    expect do
      expect(Delayed::Worker.new.work_off(1)).to eq([1, 0])
    end.to change(ActionMailer::Base.deliveries, :count).by(1)
    expect(Delayed::Job.count).to eq(0)
    mail = ActionMailer::Base.deliveries.last
    expect(mail.to).to eq([recipient.email])
    expect(mail.body.encoded).to include(request.human_state_name)
    expect(mail.body.encoded).to match("http.+/travel_sponsorships/#{request.id}")
  ensure
    Rails.configuration.site['async_emails'] = previous_setting
  end
end
