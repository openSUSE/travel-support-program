#
# Effective payment of a reimbursement
#
class Payment < ActiveRecord::Base
  # The associated reimbursement
  belongs_to :reimbursement, inverse_of: :payments

  validates :amount, :reimbursement, :currency, :date, :method, presence: true

  mount_uploader :file, AttachmentUploader

  auditable except: [:file]
end
