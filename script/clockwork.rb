require 'clockwork'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'boot'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

module Clockwork
  every(1.day, 'notify.pending') do
    date = TravelSupport::Config.setting(:days_for_reminder)
    unless date.blank?
      date = date.to_i.days.ago
      Request.notify_inactive_since date
      Reimbursement.notify_inactive_since date
    end

    end_threshold = TravelSupport::Config.setting(:reimbursement_reminder, :days_after_event)
    deadline_threshold = TravelSupport::Config.setting(:reimbursement_reminder, :days_before_deadline)
    unless end_threshold.blank? || deadline_threshold.blank?
      Request.notify_missing_reimbursement end_threshold.to_i.days, deadline_threshold.to_i.days
    end
  end
end
