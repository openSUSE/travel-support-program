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

  validates :request, :presence => true
  validates :estimated_amount, :estimated_currency, :presence => true, :if => "request.submitted?"
  validates :approved_amount, :approved_currency, :presence => true, :if => "request.approved?"
  validates :total_amount, :presence => true, :if => "request.reimbursement && request.reimbursement.tsp_pending?"
  validates :authorized_amount, :presence => true, :if => "request.reimbursement && request.reimbursement.tsp_approved?"
  
  # Convenience method that simply aliases approved_currency since currency
  # cannot be changed after approval
  def total_currency; approved_currency; end
  # (see #total_currency)
  def authorized_currency; approved_currency; end
end
