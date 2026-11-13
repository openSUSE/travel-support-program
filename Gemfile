# frozen_string_literal: true

source 'https://rubygems.org'

ruby '~> 3.4.0'

gem 'rails', '~> 8.1.4'
gem 'rails-i18n', '~> 8.0'
gem 'responders'

# Choose your weapon
gem 'pg', '~> 1.6'
gem 'sqlite3', '~> 2.1'
gem 'mysql2', '~> 0.5'

# Use SCSS for stylesheets
gem 'sass-rails'
# Bootstrap ui framework
gem 'bootstrap-sass'
# Compress modern JavaScript supplied by Rails and the asset pipeline.
gem 'terser'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# HAML as default
gem 'haml-rails'
# ExecJS uses Node.js, avoiding a platform-specific embedded V8 build.

# To test email with letter opener set the 'async_emails' option in site.yml to false
gem 'letter_opener_web'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

gem 'listen'

# Debugger
gem 'byebug', group: %i[development test]

gem 'active_hash'
gem 'audited'
gem 'cancancan'
gem 'carrierwave'
gem 'caxlsx_rails'
gem 'clockwork'
gem 'cocoon'
gem 'country_select'
gem 'daemons'
gem 'date_validator'
gem 'devise'
gem 'devise_ichain_authenticatable', '>= 0.3.0'
gem 'git'
gem 'kaminari'
gem 'prawn', '~> 2.5'
gem 'prawn-rails', '~> 1.6'
# Preserve existing check-request templates while using maintained Prawn.
gem 'hexapdf', '~> 1.0'
gem 'puma'
gem 'ransack', '>= 4.3'
gem 'show_for'
gem 'simple_form', '~> 5.3'
gem 'state_machines-activerecord'
gem 'delayed_job_active_record'

gem 'exception_notification', group: :production
gem 'redcarpet'
gem 'rspec-rails', '~> 8.0', group: %i[development test]
gem 'simplecov', require: false
gem 'simplecov-lcov', require: false

# Moved out of the development group to avoid an error in every rake execution
# caused by lib/tasks/doc.rake (at least until we figure out a cleaner
# solution)
gem 'yard', '~> 0.9.0'
group :development do
  gem 'ruby-graphviz'
  gem 'state_machines-yard'
  gem 'yard-activerecord'
  # for static code analisys
  gem 'rubocop', '~> 1.0', require: false
  gem 'rubocop-rails', '~> 2.0', require: false
  gem 'rubocop-rspec', '~> 3.0', require: false
  gem 'rubocop-capybara', require: false
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-lockstep'
  gem 'database_cleaner-active_record'
  gem 'pdf-reader'
  gem 'selenium-webdriver', '< 5.0'
  gem 'shoulda-matchers'
  #  gem "delorean"
end

# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'
