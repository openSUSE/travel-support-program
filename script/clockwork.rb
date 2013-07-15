require 'clockwork'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'boot'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

module Clockwork
  every(1.day, 'notify.pending') do
    date = TravelSupportProgram::Config.setting(:days_for_reminder)
    unless date.blank?
      date = date.to_i.days.ago
      Request.notify_inactive_since date
      Reimbursement.notify_inactive_since date
    end
  end
end
