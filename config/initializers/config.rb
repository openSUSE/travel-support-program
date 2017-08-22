TravelSupport::Config.init(Rails.env)

STATES = YAML.load_file(Rails.root.join('config', 'states.yml'))['states']
STATES.merge! STATES.fetch(Rails.env, {})

ActionMailer::Base.default_url_options = TravelSupport::Config.setting(:email_default_url_options).symbolize_keys

if theme = TravelSupport::Config.setting("theme")
  path = "#{Rails.root}/app/themes/#{theme}/"
  ActionController::Base.prepend_view_path "#{path}views"
  Rails.application.config.assets.paths.unshift "#{path}assets/images", "#{path}assets/javascripts", "#{path}assets/stylesheets"
end
