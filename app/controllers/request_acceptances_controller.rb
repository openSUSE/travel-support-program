class RequestAcceptancesController < ApplicationController
  skip_load_and_authorize_resource

  def create
    @request = Request.find(params[:request_id])
    authorize! :accept, @request
    if @request.can_accept? &&  @request.accept!
      flash[:notice]= I18n.t(:request_accepted)
    else
      flash[:error]= I18n.t(:request_acceptance_failed)
    end
    redirect_to @request
  end
end
