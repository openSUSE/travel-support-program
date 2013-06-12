#
# Helpers for user profile form
#
module UserProfilesHelper

  # Outputs a block with information to show to the user while editing his/her
  # own profile. Explains why some inputs are disabled when opensuse_auth_proxy
  # is enabled.
  #
  # @return [String] HTML output
  def profile_info
    if TravelSupportProgram::Config.setting :opensuse_auth_proxy, :enabled
      content_tag(:div,
          t(:opensuse_profile_info, :url => ConnectUser.profile_url_for(current_user.nickname)).html_safe,
          :class => "alert alert-info")
    else
      ""
    end
  end

  # Renders a input for a UserProfile's field, disabled when needed.
  #
  # @param [SimpleForm::FormBuilder] f the simple_form form builder
  # @param [Symbol] attribute the attribute name
  # @param [Hash] args arguments to bypass to the #input call
  # @return [String] HTML output
  def profile_input(f, attribute, args = {})
    if f.object.have_editable? attribute
      f.input attribute, args
    else
      f.input attribute, args.merge(disabled: true)
    end
  end
end
