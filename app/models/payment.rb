#
# Effective payment of a reimbursement
#
class Payment < ActiveRecord::Base
  attr_accessible :reimbursement_id, :date, :amount, :currency, :cost_amount,
    :cost_currency, :method, :code, :subject, :notes, :file, :file_cache

  # The associated reimbursement
  belongs_to :reimbursement, :inverse_of => :payments

  validates :amount, :reimbursement, :currency, :date, :method, :presence => true

  mount_uploader :file, AttachmentUploader

  audit(:create, :update, :destroy, :except => :file, :on => :reimbursement) {|m,u,a| "#{a} performed on Payment by #{u.try(:nickname)}"}
end
