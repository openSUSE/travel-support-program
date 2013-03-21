#
# Attachment for a given reimbursement
#
class ReimbursementAttachment < ActiveRecord::Base
  belongs_to :reimbursement

  attr_accessible :reimbursement_id, :title, :file

  validate :reimbursement, :title, :file, :presence => true

  mount_uploader :file, AttachmentUploader
end
