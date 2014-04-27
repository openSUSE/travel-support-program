#
# This class holds all the information related to every expense in a request.
#
# As there is only one reimbursement per request, RequestExpense objects hold
# information from both the Request and the Reimbursement corresponding objects,
# so total_currency and authorized_currency attributes are updated during the
# reimbursement process
#
class RequestExpense < ActiveRecord::Base
  belongs_to :request, :inverse_of => :expenses

  attr_accessible :request_id, :subject, :description, :estimated_amount,
    :estimated_currency, :approved_amount, :approved_currency, :total_amount,
    :authorized_amount

  delegate :reimbursement, :to => :request, :prefix => false
  delegate :event, :to => :request, :prefix => false

  validates :request, :subject, :presence => true
  validates :estimated_amount, :estimated_currency, :presence => true, :if => "request && request.submitted?"
  validates :approved_amount, :approved_currency, :presence => true, :if => "request && request.approved?"
  validates :total_amount, :presence => true, :if => "request && request.reimbursement && request.reimbursement.submitted?"
  validates :authorized_amount, :presence => true, :if => "request && request.reimbursement && request.reimbursement.approved?"

  before_validation :set_authorized_amount

  audit(:create, :update, :destroy, :on => :request) {|m,u,a| "#{a} performed on RequestExpense by #{u.try(:nickname)}"}

  # Scope needed by Request.expenses_sum
  scope :by_attr_for_requests, lambda {|attr, req_ids|
    currency_field = RequestExpense.currency_field_for(attr)
    amount_field = :"#{attr}_amount"
    group(currency_field).where(["#{amount_field} is not null and request_id in (?)", req_ids]).order(currency_field)
  }

  # Convenience method that simply aliases approved_currency since currency
  # cannot be changed after approval
  def total_currency
    send(RequestExpense.currency_field_for(:total))
  end
  # (see #total_currency)
  def authorized_currency
    send(RequestExpense.currency_field_for(:authorized))
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

  protected

  # Set the authorized amount if possible
  #
  # This callback sets the authorized amount as the minimum among approved and
  # total, but only if the reimbursement process has started.
  #
  # @callback
  def set_authorized_amount
    if !total_amount.blank? && !approved_amount.blank?
      if total_currency != approved_currency
        self.authorized_amount = approved_amount
      else
        self.authorized_amount = [approved_amount, total_amount].min
      end
    end
  end

end
