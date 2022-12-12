# frozen_string_literal: true

source 'https://rubygems.org'

gem 'rails', '>= 5.1.0', '< 5.1.99'
gem 'rails-i18n'
gem 'responders'

# Choose your weapon
gem 'sqlite3', '~> 1.5.4'
# gem 'pg', '~> 0.21'
# gem 'mysql2', '~> 0.4.10'

# This can only be removed with Rails 7.0
gem 'psych', '< 4.0'

# Use SCSS for stylesheets
gem 'sass-rails'
# Bootstrap ui framework
gem 'bootstrap-sass'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# HAML as default
gem 'haml-rails'
# mini_racer for execjs
gem 'mini_racer'

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
gem 'cancancan', '~> 1.17'
gem 'carrierwave'
gem 'caxlsx_rails'
gem 'clockwork'
gem 'cocoon'
gem 'country_select'
gem 'daemons'
gem 'date_validator'
gem 'devise'
gem 'devise_ichain_authenticatable', '>= 0.3.0'
gem 'espinita', git: 'https://github.com/michelson/espinita.git',
                ref: '2dc027edc838ee5de0d68558f1758273ccc01636'
gem 'git'
gem 'inherited_resources'
gem 'kaminari'
# Newer prawn lost the template support in Document
# Would be good to replace with something else
gem 'prawn', '~> 0.13.0'
gem 'prawn_rails'
gem 'puma'
gem 'ransack'
gem 'show_for'
gem 'simple_form'
gem 'state_machines-activerecord'
# delayed_job must appear after protected_attributes
gem 'delayed_job_active_record'

gem 'exception_notification', group: :production
gem 'redcarpet'
gem 'rspec-rails', group: %i[development test]
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
  gem 'rubocop', '~> 0.52.0', require: false
  # gem 'rubocop-rails', require: false
  # gem 'rubocop-rspec', require: false
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'database_cleaner'
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
