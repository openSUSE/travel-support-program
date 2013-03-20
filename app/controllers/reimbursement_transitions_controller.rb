class ReimbursementTransitionsController < ApplicationController
  skip_load_and_authorize_resource
  before_filter :load_and_authorize_reimbursement

  def new
    render @action.to_s
  end

  def create
    # FIXME temporary check, will dissapear as soon as possible
    @reimbursement.attributes = params[:reimbursement] if Reimbursement.editable_in?(@action)
    if @reimbursement.state_events.include?(@action) &&  @reimbursement.fire_state_event(@action)
      flash[:notice]= I18n.t("activerecord.state_machines.messages.#{@action}_success")
    else
      flash[:error]= I18n.t("activerecord.state_machines.messages.#{@action}_failure")
    end
    redirect_to request_reimbursement_path(@request)
  end

  protected

  def load_and_authorize_reimbursement
    @request = Request.find(params[:request_id])
    @reimbursement = @request.reimbursement
    @action = params[:transition][:action].to_sym
    authorize! @action, @reimbursement
  end
end
