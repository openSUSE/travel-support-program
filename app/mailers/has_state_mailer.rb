class HasStateMailer < ApplicationMailer

  def state(to, state_machine, state_name, state_updated_at)
    @machine = state_machine
    @state_name = state_name
    @updated_at = state_updated_at
    @transition = @machine.transitions.newest_first.first
    mail(:to => to,  :subject => t(:mailer_subject_state, :type => @machine.class.model_name, :id => @machine.id))
  end
end
