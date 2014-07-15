#
# This class holds all the information related to every expense associated to a
# Reimbursable object.
#
# As there is only one reimbursement per reimbursable object, Expense objects hold
# information from both the Reimbursable and the Reimbursement objects, so
# total_currency and authorized_currency attributes are updated during the
# reimbursement process
#
class Expense < ActiveRecord::Base
  belongs_to :request, :polymorphic => true, :inverse_of => :expenses

  delegate :reimbursement, :to => :request, :prefix => false
  delegate :event, :to => :request, :prefix => false

  validates :request, :subject, :presence => true
  validates :estimated_amount, :estimated_currency, :presence => true, :if => "request && request.submitted?"
  validates :approved_amount, :approved_currency, :presence => true, :if => "request && request.approved?"
  validates :total_amount, :presence => true, :if => "request && request.reimbursement && request.reimbursement.submitted?"
  validates :authorized_amount, :presence => true, :if => "request && request.reimbursement && request.reimbursement.submitted?"

  before_validation :set_authorized_amount

  auditable

  # Scope needed by Request.expenses_sum
  scope :by_attr_for_travel_requests, lambda {|attr, req_ids|
    currency_field = Expense.currency_field_for(attr)
    amount_field = :"#{attr}_amount"
    group(currency_field).where(["#{amount_field} is not null and request_id in (?) and request_type = ?", req_ids, 'Request']).order(currency_field)
  }

  # Convenience method that simply aliases approved_currency since currency
  # cannot be changed after approval
  def total_currency
    send(Expense.currency_field_for(:total))
  end
  # (see #total_currency)
  def authorized_currency
    send(Expense.currency_field_for(:authorized))
  end

  def self.currency_field_for(attr)
    case attr
    when :estimated
      :estimated_currency
    when :approved
      :approved_currency
    when :total
      :estimated_currency
    when :authorized
      :approved_currency
    end
  end

  # Checks whether authorized_amount can be automatically calculated or needs to
  # be manually set.
  #
  # It can only be automated if the currency for both total and approved are the
  # same, otherwise exchange rates and other rules may come into play
  #
  # @return [Boolean] true whether automatic calculation is possible
  def authorized_can_be_calculated?
    !total_currency.blank? && !approved_currency.blank? && total_currency == approved_currency
  end

  protected

  # Set the authorized amount if possible
  #
  # This callback sets the authorized amount as the minimum among approved and
  # total, but only if the reimbursement process has started and if the same
  # currency is used for total amount and approved. Otherwise, manual
  # intervention is needed to set the authorized amount.
  #
  # @callback
  def set_authorized_amount
    if !total_amount.blank? && !approved_amount.blank? && authorized_can_be_calculated?
      self.authorized_amount = [approved_amount, total_amount].min
    end
  end

end
