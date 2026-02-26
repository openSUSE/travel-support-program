# frozen_string_literal: true

class ApplicationController < ActionController::Base
  force_ssl unless: proc { Rails.env.test? || Rails.env.development? }
  before_action :authenticate_and_audit_user, unless: :devise_controller?
  load_and_authorize_resource unless: :devise_controller?
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :mailer_set_url_for_test, if: -> { devise_controller? && Rails.env.test? }
  before_action :set_breadcrumbs

  protect_from_forgery prepend: true

  rescue_from CanCan::AccessDenied do |_exception|
    flash[:alert] = nil
    render file: "#{Rails.root}/public/403.html", status: 403
  end

  protected

  def prepare_for_nested_resource
    machine = params[:machine].to_s
    klass = machine.camelize.constantize
    if machine == 'reimbursement'
      @request = Request.find(params[:request_id])
      @parent = @request.reimbursement
      @back_path = request_reimbursement_path(@request)
    else
      @parent ||= klass.find(params["#{machine}_id"])
      @back_path = url_for(@parent)
    end
  end

  def authenticate_and_audit_user
    authenticate_user!
  end

  # Can be overidden by individuals controllers. Some logic merged here, though,
  # to avoid too much spreading
  def set_breadcrumbs
    @breadcrumbs = if users_controller?
                     # For user related controllers
                     [{ label: :breadcrumb_user }]
                   else
                     [{ label: '' }]
                   end
  end

  def users_controller?
    devise_controller?
  end

  # Needed by devise in Rails 4
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
  end

  # To generate proper urls when testing the mailers ignoring the
  # email_default_url_options in config/site.yml
  # Since tests run in a random port which is only known during test execution
  def mailer_set_url_for_test
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
  end
end
