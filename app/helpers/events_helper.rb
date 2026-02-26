# frozen_string_literal: true

#
# Helpers for events
#
module EventsHelper
  # Outputs a one-line summary of the event information
  #
  # @param [Event] event the event to be displayed
  # @return [String] HTML output
  def event_title_line(event)
    t(:event_title_line, name: event.name, start: l(event.start_date),
                         end: l(event.end_date), country: event.country_code)
  end

  def users_for_event(state)
    requests = @event.travel_sponsorships.includes(:user).accessible_by(current_ability)
    requests = requests.where(state: state) if state != 'all'
    requests.distinct.order('users.email').pluck('users.email')
  end

  def state_label(state)
    case state
    when 'submitted'
      'label-primary'
    when 'canceled'
      'label-danger'
    when 'incomplete'
      'label-warning'
    when 'accepted'
      'label-success'
    when 'approved'
      'label-success'
    end
  end
end
