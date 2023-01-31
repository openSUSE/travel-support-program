# frozen_string_literal: true

class EventMailer < ApplicationMailer
  def event_info(receiver, email)
    @email = email
    mail(from: @email.user.email,
         to: receiver,
         subject: @email[:subject])
  end
end
