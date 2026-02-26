# frozen_string_literal: true

#
# Base class for all requests, reimbursable or not
#
class Request < ApplicationRecord
  include HasState
  include HasComments

  # The event associated to the state machine
  belongs_to :event

  validates :event, presence: true

  audited
end
