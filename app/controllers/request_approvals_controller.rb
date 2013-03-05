class RequestApprovalsController < ApplicationController
  skip_authorize_resource
  before_filter :load_and_authorize_request

  def create
    @request.attributes = params[:request]
    if @request.can_approve? &&  @request.approve!
      flash[:notice]= I18n.t(:request_approved)
    else
      flash[:error]= I18n.t(:request_approval_failed)
    end
    redirect_to @request
  end

  protected

  def load_and_authorize_request
    @request = Request.find(params[:request_id])
    authorize! :approve, @request
  end
end
