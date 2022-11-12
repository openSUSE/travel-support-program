class UserProfilesController < ApplicationController
  force_ssl unless: proc { Rails.env.test? || Rails.env.development? }
  before_action :set_user_and_profile

  def update
    attrs = params.require(:user).permit(:country_code, :full_name, :location,
                                         :passport, :alternate_id_document, :birthday, :phone_number,
                                         :second_phone_number, :website, :blog, :description,
                                         :postal_address, :zip_code)
    if @profile.update_attributes(attrs)
      flash[:notice] = I18n.t(:profile_updated)
      redirect_to profile_path
    else
      flash[:error] = I18n.t(:profile_update_failed)
      render 'edit'
    end
  end

  def update_password
    if @user.update_attributes(params.require(:user).permit(:password, :password_confirmation))
      # Sign in the user by passing validation in case their password changed
      bypass_sign_in @user
      flash[:notice] = I18n.t(:password_updated)
    end
    render 'password'
  end

  private

  def set_user_and_profile
    @user = current_user
    @profile = @user.find_profile
  end

  def users_controller?
    true
  end
end
