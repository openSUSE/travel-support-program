#
# Link for a given reimbursement
#
class ReimbursementLink < ActiveRecord::Base
  belongs_to :reimbursement, :inverse_of => :links

  attr_accessible :title, :url, :reimbursement_id

  validates :reimbursement, :title, :url, :presence => true

  audit(:create, :update, :destroy, :on => :reimbursement) {|m,u,a| "#{a} performed on ReimbursementLink by #{u.try(:nickname)}"}
end
