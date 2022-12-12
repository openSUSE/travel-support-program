# frozen_string_literal: true

# This controller is only used for redirecting to keep some compatibility with
# the old names (before renaming Request to TravelSponsorship)
class RequestsController < ApplicationController
  respond_to :html

  skip_load_and_authorize_resource

  # People looking for /requests probably want the list of travel sponsorships
  def index
    redirect_to travel_sponsorships_path
  end

  # Redirect to the proper controller
  def show
    @request = Request.find(params[:id])
    redirect_to @request
  end
end
