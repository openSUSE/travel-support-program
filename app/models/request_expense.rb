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

  validates :request, :subject, :presence => true
  validates :estimated_amount, :estimated_currency, :presence => true, :if => "request.submitted?"
  validates :approved_amount, :approved_currency, :presence => true, :if => "request.approved?"
  validates :total_amount, :presence => true, :if => "request.reimbursement && request.reimbursement.tsp_pending?"
  validates :authorized_amount, :presence => true, :if => "request.reimbursement && request.reimbursement.tsp_approved?"

  before_validation :set_authorized_amount

  audit(:create, :update, :destroy, :on => :request) {|m,u,a| "#{a} performed on RequestExpense by #{u.try(:nickname)}"}

  # Convenience method that simply aliases approved_currency since currency
  # cannot be changed after approval
  def total_currency; estimated_currency; end
  # (see #total_currency)
  def authorized_currency; approved_currency; end

  protected

  # Set the authorized amount if possible and not already set/reviewed by a TSP
  # member
  #
  # This callback sets the authorized amount as the minimum among approved and
  # total, but only if the reimbursement process has started and if the
  # reimbursement has neven been submited. After first submission the authorized
  # amount is never changed automatically, to avoid confussion.
  #
  # @callback
  def set_authorized_amount
    if !total_amount.blank? && !approved_amount.blank? && reimbursement && !reimbursement.with_transitions?
      if total_currency != approved_currency
        self.authorized_amount = approved_amount
      else
        self.authorized_amount = [approved_amount, total_amount].min
      end
    end
  end

end
