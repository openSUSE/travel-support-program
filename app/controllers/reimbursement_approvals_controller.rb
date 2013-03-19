class ReimbursementApprovalsController < ApplicationController
  skip_load_and_authorize_resource
  before_filter :load_and_authorize_reimbursement

  def create
    @reimbursement.attributes = params[:reimbursement]
    if @reimbursement.can_approve? &&  @reimbursement.approve!
      flash[:notice]= I18n.t(:reimbursement_approved)
    else
      flash[:error]= I18n.t(:reimbursement_approval_failed)
    end
    redirect_to request_reimbursement_path(@request)
  end

  protected

  def load_and_authorize_reimbursement
    @request = Request.find(params[:request_id])
    @reimbursement = @request.reimbursement
    authorize! :approve, @reimbursement
  end
end
