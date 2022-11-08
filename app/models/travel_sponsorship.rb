#
# Request from a user to get help from the TSP for a given event
#
class TravelSponsorship < ReimbursableRequest
  validate :only_one_active_request, if: :active?
  validate :dont_exceed_budget, if: :approved?

  scope :in_conflict_with, lambda { |req|
    others = active.where(user_id: req.user_id, event_id: req.event_id)
    others = others.where(['id <> ?', req.id]) if req.id
    others
  }

  # @see HasComments.allow_all_comments_to
  allow_all_comments_to [:tsp, :assistant]
  # @see HasComments.allow_public_comments_to
  allow_public_comments_to [:administrative, :requester]

  state_machine :state, initial: :incomplete do |_machine|
    event :submit do
      transition incomplete: :submitted, unless: :has_no_expenses?
    end

    event :approve do
      transition submitted: :approved
    end

    event :accept do
      transition approved: :accepted
    end

    event :roll_back do
      # Separated transitions because grouping them using arrays confuses the
      # Graphviz task for automatic documentation
      transition submitted: :incomplete
      transition approved: :incomplete
    end

    # The empty block for this state is needed to prevent yardoc's error
    # during automatic documentation generation
    state :canceled do
    end
  end

  # @see HasState.assign_state
  # @see HasState.notify_state
  assign_state :incomplete, to: :requester
  notify_state :incomplete, to: [:requester, :tsp, :assistant],
                            remind_to: :requester,
                            remind_after: 5.days

  assign_state :submitted, to: :tsp
  notify_state :submitted, to: [:requester, :tsp, :assistant],
                           remind_after: 10.days

  assign_state :approved, to: :requester
  notify_state :approved, to: [:requester, :tsp, :assistant],
                          remind_to: :requester,
                          remind_after: 5.days

  notify_state :accepted, to: [:requester, :tsp, :assistant]

  notify_state :canceled, to: [:requester, :tsp, :assistant]

  # @see HasState.allow_transition
  allow_transition :submit, :requester
  allow_transition :approve, :tsp
  allow_transition :accept, :requester
  allow_transition :roll_back, [:requester, :tsp]

  def allow_cancel?(role_name)
    r = role_name.to_sym
    [:requester, :supervisor].include?(r) || (r == :tsp && !accepted?)
  end

  # Checks whether the request is ready for reimbursement
  #
  # @return [Boolean] true if all conditions are met
  def can_have_reimbursement?
    accepted? && (!reimbursement.nil? || event.accepting_reimbursements?)
  end

  # Check wheter the visa_letter attribute can be used
  #
  # @return [Boolean] true if the requester can ask for visa letter
  def visa_letter_allowed?
    event.try(:visa_letters) == true
  end

  protected

  def only_one_active_request
    if TravelSponsorship.in_conflict_with(self).count > 0
      errors.add(:event_id, :only_one_active)
    end
  end

  # Validates that the approved amount doesn't exceed the total of the budgets
  # associated to the event.
  def dont_exceed_budget
    if Rails.configuration.site['budget_limits']
      budget = event.budget
      currency = budget ? budget.currency : nil

      # With the current implementation, it should be only one approved currency
      if currency.nil? || expenses.any? { |e| e.approved_currency != currency }
        errors.add(:expenses, :no_budget_found)
        return
      end

      # Expenses for other requests using the same budget
      more_expenses = RequestExpense.includes(request: [:event, :reimbursement])
      more_expenses = more_expenses.where('events.budget_id' => budget.id)
      more_expenses = more_expenses.where('request_expenses.approved_currency' => currency)
      more_expenses = more_expenses.where(['requests.id <> ?', id])
      more_expenses = more_expenses.where(['requests.state in (?)', %w[approved accepted]])
      # If the request have a canceled reimbursement, it means that the money is in fact available
      more_expenses = more_expenses.where(['reimbursements.id is null or reimbursements.state <> ?', 'canceled'])

      total = more_expenses.where(['authorized_amount is null']).sum(:approved_amount) +
              more_expenses.where(['authorized_amount is not null']).sum(:authorized_amount) +
              expenses.to_a.sum(&:approved_amount)
      errors.add(:expenses, :budget_exceeded) if total > budget.amount
    end
  end

  # Sends notifications about requests lacking a reimbursement.
  #
  # Looks for events that finished some days ago or that are about to reach the
  # reimbursement deadline and sends a reminder for every request associated to
  # those events and lacking a reimbursement object.
  #
  # @param [#to_i]  after_end_threshold  number of days after the event to start
  #                 sending reminders
  # @param [#to_i]  before_deadline_threshold  number of days before the
  #                 reimbursement deadline to start sending reminders
  def self.notify_missing_reimbursement(after_end_threshold, before_deadline_threshold)
    now = Time.zone.now
    # Skip events finished more than 6 months ago to keep the size under control
    candidate_events = Event.where(
      ['(end_date > ? and end_date < ?) or '\
        '(reimbursement_creation_deadline > ? and reimbursement_creation_deadline < ?)',
       now - 6.months, now - after_end_threshold, now, now + before_deadline_threshold]
    )
    candidate_events.includes(:requests).each do |e|
      e.requests.each do |r|
        if r.lacks_reimbursement?
          ReimbursableRequestMailer.notify_to([r.user], :missing_reimbursement, r)
        end
      end
    end
  end
end
