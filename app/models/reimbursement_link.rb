#
# Link for a given reimbursement
#
class ReimbursementLink < ActiveRecord::Base
  # The associated reimbursement
  belongs_to :reimbursement, :inverse_of => :links

  validates :reimbursement, :title, :url, :presence => true

  auditable
end
