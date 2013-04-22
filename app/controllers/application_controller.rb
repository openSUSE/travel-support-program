class ApplicationController < ActionController::Base
  extend TravelSupportProgram::ForceSsl

  force_ssl_if_available
  before_filter :authenticate_user!, :unless => :devise_controller?
  before_filter :set_return_to
  load_and_authorize_resource :unless => :devise_controller?

  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    flash[:alert] = nil
    render :file => "#{Rails.root}/public/403.html", :status => 403
  end

  protected

  def set_return_to
    if params['return_to_host']
      @return_to_host = params['return_to_host']
    else
      # we have a proxy in front of us
      @return_to_host = TravelSupportProgram::Config.setting(:external_protocol) || "http"
      @return_to_host += "://"
      @return_to_host += TravelSupportProgram::Config.setting(:external_host) || request.host
    end
    @return_to_path = params['return_to_path'] || request.env['ORIGINAL_FULLPATH']
  end

end
