class StateTransitionsController < ApplicationController
  respond_to :html, :json, :js
  skip_load_and_authorize_resource
  before_filter :load_transition_and_authorize

  def create
    @state_transition.user = current_user
    if @state_transition.save
      flash[:notice] = t("activerecord.state_machines.messages.#{@state_transition.state_event}_success")
    else
      flash[:error] = t("activerecord.state_machines.messages.#{@state_transition.state_event}_failure")
    end
    respond_with(@state_transition, :location => @back)
  end

  protected

  def load_transition_and_authorize
    @request = Request.find(params[:request_id])
    if request.fullpath.include?("/reimbursement/")
      parent = @reimbursement = @request.reimbursement
      @back = request_reimbursement_path(@request)
    else
      parent = @request
      @back = request_path(@request)
    end
    @state_transition = parent.transitions.build(params[:state_transition])
    authorize! @state_transition.state_event.to_sym, parent
  end
end
