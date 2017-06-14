class EventMailer < ApplicationMailer

  def event_info(to,email)
    @email = email
    mail(:to => to,
         :subject => @email[:subject])
  end
end
