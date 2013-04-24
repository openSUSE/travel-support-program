module UserProfilesHelper

  def profile_info
    if TravelSupportProgram::Config.setting :opensuse_auth_proxy, :enabled
      content_tag(:div,
          t(:opensuse_profile_info, :url => ConnectUser.profile_url_for(current_user.nickname)).html_safe,
          :class => "alert alert-info")
    else
      ""
    end
  end

  def profile_input(f, attribute, args = {})
    if f.object.have_editable? attribute
      f.input attribute, args
    else
      f.input attribute, args.merge(disabled: true)
    end
  end
end
