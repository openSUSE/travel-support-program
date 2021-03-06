class PagesController < ApplicationController
  respond_to :html
  skip_before_action :authenticate_and_audit_user
  skip_load_and_authorize_resource

  protected

  def set_breadcrumbs
    @breadcrumbs = [{ label: :breadcrumb_userguide }]
  end
end
