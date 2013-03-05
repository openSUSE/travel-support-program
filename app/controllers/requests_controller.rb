class RequestsController < InheritedResources::Base
  respond_to :html, :js, :json

  def create
    @request = Request.new(params[:request])
    @request.user = current_user
    create!
  end
end
