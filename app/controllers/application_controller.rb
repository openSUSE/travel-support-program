class ApplicationController < ActionController::Base
  extend TravelSupportProgram::ForceSsl

  force_ssl_if_available
  before_filter :authenticate_and_audit_user, :unless => :devise_controller?
  load_and_authorize_resource :unless => :devise_controller?
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :mailer_set_url_for_test, if: "devise_controller? && Rails.env.test?"
  before_filter :set_breadcrumbs

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

  def authenticate_and_audit_user
    authenticate_user!
    Auditor::User.current_user = current_user
  end

  # Can be overidden by individuals controllers. Some logic merged here, though,
  # to avoid too much spreading
  def set_breadcrumbs
    # For user related controllers
    if users_controller?
      @breadcrumbs = [{:label => :breadcrumb_user}]
    # For inherited_resources controllers (the respond_to alternative looks
    # cleaner, but it's not working despite the method existing)
    # elsif respond_to? :association_chain
    elsif kind_of? InheritedResources::Base
      @breadcrumbs = [ {:label => resource_class.model_name.human(:count => 2),
                      :url => collection_path} ]
      if %w(show edit update).include? action_name
        @breadcrumbs << {:label => resource, :url => resource_path}
      end
    else
      @breadcrumbs = [{:label => ""}]
    end
  end

  def users_controller?
    devise_controller?
  end

  # Needed by devise in Rails 4
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :nickname
  end

  # To generate proper urls when testing the mailers ignoring the
  # email_default_url_options in config/site.yml
  # Since tests run in a random port which is only known during test execution
  def mailer_set_url_for_test
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end
