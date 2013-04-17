TravelSupportProgram::Config.init(Rails.env)

ActionMailer::Base.default_url_options = TravelSupportProgram::Config.setting(:email_default_url_options).symbolize_keys
