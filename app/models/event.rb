# frozen_string_literal: true

#
# Event is, in some way, the root of the model's hierarchy since any
# Request and any Reimbursement are always associated with an event
#
# Most attributes are self-explanatory except, maybe, the one boolean called
# 'validated'. This attribute is used to control which users can create, update
# and destroy the event.
#
class Event < ApplicationRecord
  # Requests for attending the event
  has_many :requests, inverse_of: :event, dependent: :restrict_with_exception
  # Shipment requests for merchandising
  has_many :shipments, inverse_of: :event, dependent: :restrict_with_exception
  # Travel requests for an event
  has_many :travel_sponsorships, inverse_of: :event, dependent: :restrict_with_exception
  # Mails for an event
  has_many :event_emails
  # Event Organizers for the event
  has_many :event_organizers
  # Budget to use as a limit for approved amounts
  belongs_to :budget, optional: true

  validates :name, :start_date, :end_date, :country_code, presence: true
  validates :end_date, date: { after_or_equal_to: :start_date }

  auditable

  default_scope { order('name asc') }

  # Checks whether the event can be freely updated or destroyed by all users.
  #
  # @return [Boolean] true if any user can modify the object, false if only
  #     authorized users can do it
  def editable_by_requesters?
    !validated
  end

  # Checks whether a user should be allowed to completely delete the event.
  #
  # @return [Boolean] true if allowed
  def can_be_destroyed?
    requests.empty? && shipments.empty?
  end

  # Check if new requests can be created based on request_creation_deadline
  # and start_date
  #
  # @return [Boolean] true if accepting new requests
  def accepting_requests?
    return false unless Rails.configuration.site['travel_sponsorships']['enabled']
    if request_creation_deadline
      Time.zone.now < request_creation_deadline
    else
      begin
        (Date.today < start_date)
      rescue
        false
      end
    end
  end

  # Check if new reimbursements can be created based on reimbursement_creation_deadline
  #
  # @return [Boolean] true if accepting new reimbursements
  def accepting_reimbursements?
    if reimbursement_creation_deadline
      Time.zone.now < reimbursement_creation_deadline
    else
      true
    end
  end

  # Check if new shipment can be created based on shipment_type
  # and start_date
  #
  # @return [Boolean] true if accepting new shipments
  def accepting_shipments?
    return false unless Rails.configuration.site['shipments']['enabled']
    begin
      (!shipment_type.blank? && Date.today < start_date)
    rescue
      false
    end
  end

  # List of attributed that can only by accessed by users who have validation
  # permissions on the event.
  #
  # @return [Array] a list of the restricted attribute names as symbols
  def self.validation_attributes
    %i[validated visa_letters request_creation_deadline reimbursement_creation_deadline shipment_type]
  end
end
