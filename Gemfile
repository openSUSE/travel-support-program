source 'https://rubygems.org'

gem 'rails', '4.2.11.3'
gem 'responders', '~> 2.0'

# Choose your weapon
gem 'sqlite3', '~> 1.3.13'
# gem 'pg', '~> 0.21'
# gem 'mysql2', '~> 0.4.10'

gem 'bigdecimal', '1.3.5'
gem 'bundler', '< 2.0'
gem 'psych', '< 4.0'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# HAML as default
gem 'haml-rails'
# To test email with letter opener set the 'async_emails' option in site.yml to false
gem 'letter_opener_web'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Debugger
gem 'byebug', group: [:development, :test]

# less support
gem 'less-rails'
gem 'mini_racer', platforms: :ruby
# Remove therubyracer as soon as there's no less-rails anymore
gem 'therubyracer', platforms: :ruby
gem 'twitter-bootstrap-rails'

gem 'active_hash'
gem 'caxlsx_rails'
gem 'cancancan', '~> 1.7'
gem 'carrierwave'
gem 'clockwork'
gem 'cocoon'
gem 'daemons'
gem 'date_validator'
gem 'devise'
gem 'devise_ichain_authenticatable', '>= 0.3.0'
gem 'espinita'
gem 'inherited_resources'
gem 'kaminari'
gem 'localized_country_select'
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
gem 'rspec-rails', group: [:development, :test]
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
  gem 'rubocop', '~> 0.49.1', require: false
  gem 'web-console', '~> 2.0'
end

group :test do
  gem 'capybara'
  gem 'capybara-email'
  gem 'database_cleaner'
  gem 'pdf-reader'
  gem 'selenium-webdriver', '< 4.0'
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

# To use debugger
# gem 'debugger'
