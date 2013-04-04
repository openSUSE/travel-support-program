TravelSupportProgram::Config.init(Rails.env)

TravelSupportProgram::Application.configure do
  config.action_mailer.default_url_options ||= {:host => TravelSupportProgram::Config(:email_base_url)}
end

