ActionMailer::Base.default_url_options = Rails.configuration.site['email_default_url_options'].symbolize_keys

if theme = Rails.configuration.site['theme']
  path = "#{Rails.root}/app/themes/#{theme}/"
  ActionController::Base.prepend_view_path "#{path}views"
  Rails.application.config.assets.paths.unshift "#{path}assets/images", "#{path}assets/javascripts", "#{path}assets/stylesheets"
end
