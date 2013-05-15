TravelSupportProgram::Config.init(Rails.env)

ActionMailer::Base.default_url_options = TravelSupportProgram::Config.setting(:email_default_url_options).symbolize_keys

if theme = TravelSupportProgram::Config.setting("theme")
  path = "#{Rails.root}/app/themes/#{theme}/"
  ActionController::Base.prepend_view_path "#{path}views"
  Rails.application.config.assets.paths.unshift "#{path}assets/images", "#{path}assets/javascripts", "#{path}assets/stylesheets"
end
