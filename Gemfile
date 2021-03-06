source 'https://rubygems.org'

gem 'rails', '6.1.2'
gem 'responders', '~> 3.0'

# Choose your weapon
gem 'sqlite3', '~> 1.4'
# gem 'pg', '~> 0.21'
# gem 'mysql2', '~> 0.4.10'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 6.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 4.2.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 5.0.0'
# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# HAML as default
gem 'haml-rails'
# To test email with letter opener set the 'async_emails' option in site.yml to false
gem 'letter_opener_web'

gem 'rails-i18n'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Debugger
gem 'byebug', group: [:development, :test]

# less support
gem 'less-rails'
gem 'therubyracer', platforms: :ruby
gem 'twitter-bootstrap-rails'

gem 'active_hash'
gem 'caxlsx_rails'
gem 'cancancan', '~> 3.2'
gem 'carrierwave'
gem 'clockwork'
gem 'cocoon'
gem 'daemons'
gem 'date_validator'
gem 'devise'
gem 'devise_ichain_authenticatable', '>= 0.3.0'
# using the git version since it fixes incompatibility with rails > 5.1
gem 'espinita', git: 'https://github.com/michelson/espinita.git'
gem 'inherited_resources'
gem 'kaminari'
gem 'localized_country_select'
gem 'prawn', '>= 2.4'
gem 'prawn_rails'
gem 'puma'
gem 'ransack'
gem 'show_for'
gem 'simple_form'
gem 'state_machines-activerecord'
# delayed_job must appear after protected_attributes
gem 'delayed_job_active_record'

gem 'coveralls', require: false
gem 'exception_notification', group: :production
gem 'redcarpet'
gem 'rspec-rails', group: [:development, :test]

# Moved out of the development group to avoid an error in every rake execution
# caused by lib/tasks/doc.rake (at least until we figure out a cleaner
# solution)
gem 'yard', '~> 0.9.0'
group :development do
  gem 'ruby-graphviz'
  gem 'state_machines-yard'
  gem 'yard-activerecord'
  # for static code analisys
  gem 'rubocop', '~> 1.11', require: false
  gem 'web-console', '~> 4.1'
end

group :test do
  gem 'capybara', '>= 3.0'
  gem 'capybara-email'
  gem 'webdrivers'
  gem 'capybara-selenium'
  gem 'database_cleaner', '~> 2.0'
  gem 'pdf-reader', '~> 2.4'
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
