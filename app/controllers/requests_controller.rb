class RequestsController < InheritedResources::Base
  force_ssl_if_available
  before_filter :authenticate_user!
  respond_to :html, :js, :json
  authorize_resource

  def create
    @request = Request.new(params[:request])
    @request.user = current_user
    create!
  end
end
