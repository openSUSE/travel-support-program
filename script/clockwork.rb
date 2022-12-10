# frozen_string_literal: true

require 'clockwork'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'boot'))
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'config', 'environment'))

module Clockwork
  every(1.day, 'notify.pending') do
    Request.notify_inactive
    Reimbursement.notify_inactive

    end_threshold = Rails.configuration.site['reimbursement_reminder']['days_after_event']
    deadline_threshold = Rails.configuration.site['reimbursement_reminder']['days_before_deadline']
    unless end_threshold.blank? || deadline_threshold.blank?
      TravelSponsorship.notify_missing_reimbursement end_threshold.to_i.days, deadline_threshold.to_i.days
    end
  end
end
