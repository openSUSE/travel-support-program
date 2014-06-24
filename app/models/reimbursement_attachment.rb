#
# Attachment for a given reimbursement
#
class ReimbursementAttachment < ActiveRecord::Base
  # The associated reimbursement
  belongs_to :reimbursement

  validates :reimbursement, :title, :file, :presence => true

  mount_uploader :file, AttachmentUploader

  auditable :except => [:file]

  # Changed is ovewritten to avoid losing the already uploaded file when
  # saving the reimbursement fails in some very specific situations
  #
  # @return [boolean] true if really changed or there is a cached file
  def changed?
    super || !file_cache.blank?
  end
end
