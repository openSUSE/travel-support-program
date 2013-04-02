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
end
