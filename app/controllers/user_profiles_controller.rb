class UserProfilesController < ApplicationController
  force_ssl_if_available
  before_filter :authenticate_user!
  before_filter :set_profile

  def update
    if @profile.update_attributes(params[:user])
      flash[:notice] = I18n.t(:profile_updated)
      redirect_to profile_path
    else
      flash[:error] = I18n.t(:profile_update_failed)
      render "edit"
    end
  end

  def update_password
    @user = current_user
    if @user.update_attributes(params[:user])
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      flash[:notice] = I18n.t(:password_updated_for)
    end
    render "password"
  end

  private
  
  def set_profile
    @profile = current_user.find_profile
  end

end
