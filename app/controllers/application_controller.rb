class ApplicationController < ActionController::Base
  extend TravelSupportProgram::ForceSsl

  protect_from_forgery
end
