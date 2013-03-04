module TravelSupportProgram::ForceSsl
  def force_ssl_if_available(args = {})
    force_ssl(*args) unless Rails.env.test?
  end
end
