class ReimbursementsController < InheritedResources::Base
  respond_to :html, :js, :json, :pdf
  load_and_authorize_resource :request
  load_and_authorize_resource :reimbursement, :through => :request, :singleton => true, :except => [:create]

  defaults :singleton => true
  belongs_to :request

  def create
    if parent.reimbursement.nil? || parent.reimbursement.new_record?
      @reimbursement = Reimbursement.new
      @reimbursement.request = parent
      create! {edit_resource_path}
    else
      redirect_to edit_resource_path
    end
  end

  def show
    # We don't want to break the normal process if something goes wrong
    resource.user.profile.refresh rescue nil
    show!
  end
end
