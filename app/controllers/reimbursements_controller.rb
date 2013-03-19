class ReimbursementsController < InheritedResources::Base
  respond_to :html, :js, :json
  load_and_authorize_resource :request
  load_and_authorize_resource :reimbursement, :through => :request, :singleton => true, :except => [:create]

  belongs_to :request, :singleton => true

  def create
    if parent.reimbursement.nil? || parent.reimbursement.new_record?
      @reimbursement = Reimbursement.new
      @reimbursement.request = parent
      create! {edit_resource_path}
    else
      redirect_to edit_resource_path
    end
  end
end
