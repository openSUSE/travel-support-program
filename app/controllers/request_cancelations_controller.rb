class RequestCancelationsController < ApplicationController
  skip_load_and_authorize_resource

  def create
    @request = Request.find(params[:request_id])
    authorize! :cancel, @request
    if @request.can_submit? &&  @request.submit!
      flash[:notice]= I18n.t(:request_canceled)
    else
      flash[:error]= I18n.t(:request_cancelation_failed)
    end
    redirect_to @request
  end
end
