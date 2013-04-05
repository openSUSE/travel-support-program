class HasStateMailer < ActionMailer::Base
  helper ApplicationHelper
  default :from => lambda { TravelSupportProgram::Config.setting(:email_from) }

  def state(to, state_machine, state_name, state_updated_at)
    @machine = state_machine
    @state_name = state_name
    @updated_at = state_updated_at
    mail(:to => to,  :subject => t(:mailer_subject_state, :type => @machine.class.model_name, :state => state_name))
  end

  def self.notify_state(machine, roles)
    HasStateMailer.notify(:state, machine.user.email,
                                  machine,
                                  machine.human_state_name,
                                  machine.state_updated_at)
    roles.each do |role|
      User.with_role(role).each do |u|
        HasStateMailer.notify(:state, u.email,
                                      machine,
                                      machine.human_state_name,
                                      machine.state_updated_at)
      end
    end
    true
  end

  def self.notify(method, *args)
   if TravelSupportProgram::Config.setting(:async_emails)
      HasStateMailer.delay.send(method, *args)
    else
      HasStateMailer.send(method, *args).deliver
    end
  end
end
