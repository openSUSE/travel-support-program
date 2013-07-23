class IchainRegistrationsController < Devise::IchainRegistrationsController

  protected

  def after_update_path_for(resource)
    edit_user_ichain_registration_path
  end
end
