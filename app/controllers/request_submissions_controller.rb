class RequestSubmissionsController < ApplicationController

  def create
    @request = Request.find(params[:request_id])
    if @request.can_submit? &&  @request.submit!
      flash[:notice]= I18n.t(:request_submitted)
    else
      flash[:error]= I18n.t(:request_submission_failed)
    end
    redirect_to @request
  end
end
