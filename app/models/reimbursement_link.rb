# frozen_string_literal: true

#
# Link for a given reimbursement
#
class ReimbursementLink < ApplicationRecord
  # The associated reimbursement
  belongs_to :reimbursement, inverse_of: :links

  validates :reimbursement, :title, :url, presence: true

  audited
end
