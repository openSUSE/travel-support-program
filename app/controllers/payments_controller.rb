class PaymentsController < InheritedResources::Base
  respond_to :html, :json
  load_and_authorize_resource :request
  load_and_authorize_resource :reimbursement, :through => :request, :singleton => true
  load_and_authorize_resource :through => :request

  before_filter :load_methods

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

  protected

  def load_methods
    @methods = TravelSupportProgram::Config.setting :payment_methods
  end
end
