# frozen_string_literal: true

class EventMailer < ApplicationMailer
  def event_info(to, email)
    @email = email
    mail(from: @email.user.email,
         to: to,
         subject: @email[:subject])
  end
end
