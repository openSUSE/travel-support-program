ActionMailer::Base.default_url_options = Rails.configuration.site['email_default_url_options'].symbolize_keys

if theme = Rails.configuration.site['theme']
  path = Rails.root.join('app/themes', theme)
  ActionController::Base.prepend_view_path path.join('views')
  Rails.application.config.assets.paths.unshift path.join('assets/images'), path.join('assets/javascripts'), path.join('assets/stylesheets')
  Sprockets.prepend_path(path.join('assets/config'))
  Sprockets.prepend_path(path.join('assets/stylesheets'))
  Sprockets.prepend_path(path.join('assets/javascripts'))
end
