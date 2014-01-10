class PaymentsController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource :request
  load_and_authorize_resource :reimbursement, :through => :request, :singleton => true
  load_and_authorize_resource :through => :request
  skip_authorize_resource :only => :file

  before_filter :load_methods, :except => :file

  belongs_to :request
  belongs_to :reimbursement, :singleton => true

  def create
    create! { parent_url }
  end

  def update
    update! { parent_url }
  end

  def destroy
    destroy! { parent_url }
  end

  def file
    authorize! :update, resource
    send_file resource.file.path
  end

  protected

  def load_methods
    @methods = TravelSupport::Config.setting :payment_methods
  end

  def set_breadcrumbs
    @breadcrumbs = [ :label => parent.request, :url => parent.request ]
    @breadcrumbs << { :label => Reimbursement.model_name.human,
                      :url => request_reimbursement_path(parent.request)}
    @breadcrumbs << {:label => Payment.model_name.human(:count => 2) }
  end
end
