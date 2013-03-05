class RequestSubmissionsController < ApplicationController
  skip_load_and_authorize_resource

  def create
    @request = Request.find(params[:request_id])
    authorize! :submit, @request
    if @request.can_submit? &&  @request.submit!
      flash[:notice]= I18n.t(:request_submitted)
    else
      flash[:error]= I18n.t(:request_submission_failed)
    end
    redirect_to @request
  end
end
