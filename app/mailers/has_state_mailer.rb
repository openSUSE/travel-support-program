class HasStateMailer < ApplicationMailer

  def state(to, state_machine)
    @machine = state_machine
    @state_name = @machine.human_state_name
    @updated_at = @machine.state_updated_at
    @change = @machine.state_changes.newest_first.first
    mail(:to => to,  :subject => t(:mailer_subject_state, :machine => @machine.title))
  end
end
