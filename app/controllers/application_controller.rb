class ApplicationController < ActionController::Base
  extend TravelSupportProgram::ForceSsl

  force_ssl_if_available
  before_filter :authenticate_user!, :unless => :devise_controller?
  load_and_authorize_resource :unless => :devise_controller?

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = nil
    render :file => "#{Rails.root}/public/403.html", :status => 403
  end

  protected

  def prepare_for_nested_resource
    @request ||= Request.find(params[:request_id])
    if request.fullpath.include?("/reimbursement/")
      @parent = @reimbursement = @request.reimbursement
      @back_path = request_reimbursement_path(@request)
    else
      @parent = @request
      @back_path = request_path(@request)
    end
  end

end
