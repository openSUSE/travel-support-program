class ReimbursementSubmissionsController < ApplicationController
  skip_load_and_authorize_resource

  def create
    @request = Request.find(params[:request_id])
    @reimbursement = @request.reimbursement
    authorize! :submit, @reimbursement
    if @reimbursement.can_submit? &&  @reimbursement.submit!
      flash[:notice]= I18n.t(:reimbursement_submitted)
    else
      flash[:error]= I18n.t(:reimbursement_submission_failed)
    end
    redirect_to request_reimbursement_path(@request)
  end
end
