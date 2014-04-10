source 'https://rubygems.org'

gem 'rails', '4.0.2'

# Choose your weapon
gem 'sqlite3'
#gem 'pg'
#gem 'mysql2'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# HAML as default
gem 'haml-rails'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# less support
gem 'therubyracer', platforms: :ruby
gem "less-rails"
gem "twitter-bootstrap-rails"

gem 'devise'
gem 'devise_ichain_authenticatable', '>= 0.3.0'
gem 'cancancan', '~> 1.7'
gem 'simple_form'
gem 'show_for'
gem 'inherited_resources'
gem 'localized_country_select'
gem "active_hash"
gem 'cocoon'
gem 'ransack'
gem 'kaminari'
gem 'carrierwave'
gem 'daemons'
gem 'delayed_job_active_record'
gem 'date_validator'
gem 'auditor'
gem 'prawn_rails'
gem 'axlsx_rails'
gem 'clockwork'
gem "state_machine"
# Added to avoid an error in every rake execution caused by lib/tasks/doc.rake
# (at least until we figure out a cleaner solution)
gem "yard"
# For using rails3-style attributes protection
gem 'protected_attributes'

gem "rspec-rails", group: [:development, :test]
gem 'exception_notification', group: :production

group :development do
  gem "yard-activerecord"
  gem 'ruby-graphviz'
  gem "redcarpet", :require => false
end

group :test do
  gem "capybara"
  gem "capybara-email"
  gem "capybara-webkit"
  gem "shoulda-matchers"
  gem "database_cleaner"
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

# To use debugger
# gem 'debugger'
