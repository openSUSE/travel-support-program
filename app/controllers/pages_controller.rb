class PagesController < ApplicationController
  respond_to :html
  skip_before_filter :authenticate_user!
  skip_load_and_authorize_resource
end
