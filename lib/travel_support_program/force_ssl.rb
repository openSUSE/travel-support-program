#
# Module for application-wide code
#
module TravelSupportProgram::ForceSsl
  # Before filter for redirecting to the SSL-enabled version of the url
  def force_ssl_if_available(args = {})
    force_ssl(*args) unless Rails.env.test?
  end
end
