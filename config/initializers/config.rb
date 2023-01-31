# The configuration file for the application
Rails.application.config.site = Rails.application.config_for(:site)

ActionMailer::Base.default_url_options = Rails.configuration.site['email_default_url_options'].symbolize_keys

# Allow some data types to be included in activerecord
Rails.application.config.active_record.yaml_column_permitted_classes = [Symbol, BigDecimal, ActiveSupport::TimeWithZone, Time, ActiveSupport::TimeZone, Date]
