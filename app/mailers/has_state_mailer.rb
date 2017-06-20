class HasStateMailer < ApplicationMailer
  def state(to, state_machine)
    @machine = state_machine
    @state_name = @machine.human_state_name
    @updated_at = @machine.state_updated_at
    @change = @machine.state_changes.newest_first.first
    mail(to: to,
         subject: t(:mailer_subject_state,
                    machine: @machine.title,
                    user: @machine.user.nickname,
                    # With the current implementation the #try is not
                    # required (Request and Reimbursement always respond to
                    # #event), but better stay safe for future classes
                    # performing "include HasState"
                    event: @machine.try(:event).try(:name)))
  end
end
