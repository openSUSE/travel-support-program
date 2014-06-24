class RegistrationsController < Devise::RegistrationsController
  def update
    # required for settings form to submit when password is left blank
    if params[:user][:password].blank?
      params[:user].delete("password")
      params[:user].delete("password_confirmation")
    end

    @user = User.find(current_user.id)
    attrs = params.require(:user).permit(:nickname, :email, :locale)
    if @user.update_attributes(attrs)
      # Sign in the user bypassing validation in case his password changed
      #set_flash_key :notice, :updated
      flash[:notice] = 'Dreamland'
      sign_in @user, :bypass => true
      set_flash_message :notice, :updated
      redirect_to edit_user_registration_path
    else
      set_flash_message :alert, :update_failed
      render "edit"
    end
  end
end
