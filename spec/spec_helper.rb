# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'

# First of all, coveralls
require 'simplecov'
require 'simplecov-lcov'
SimpleCov.start 'rails' do
  SimpleCov::Formatter::LcovFormatter.config do |c|
    c.report_with_single_file = true
    c.single_report_path = 'coverage/lcov.info'
  end

  formatter SimpleCov::Formatter::LcovFormatter

  # Not covered because they are overriden in spec/support/carrierwave.rb
  add_filter 'app/uploaders/'
end

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'capybara/email/rspec'
require 'database_cleaner'

ActiveRecord::Migration.maintain_test_schema!

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include(Shoulda::Matchers::ActiveModel)
  config.include(Shoulda::Matchers::ActiveRecord)
  config.expect_with(:rspec) { |expectations| expectations.syntax = %i[should expect] }

  Capybara.register_driver :headless do |app|
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    options.add_argument('--no-sandbox')
    options.add_argument('--disable-gpu')

    options.add_preference(:download, default_directory: 'tmp/downloads/', directory_upgrade: true)
    Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  end

  Capybara.default_driver = :headless
  Capybara.javascript_driver = :headless

  # ## Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # Stop ActiveRecord from wrapping tests in transactions
  config.use_transactional_fixtures = false

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.before(:each) do
    DatabaseCleaner.strategy = :deletion
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.before(:all) do
    FileUtils.rm_rf('public/spec')
    FileUtils.mkdir('public/spec')
    FileUtils.cp_r('spec/support/uploads', 'public/spec')
    DatabaseCleaner.clean_with(:deletion) # Just in case
  end

  config.after(:all) do
    FileUtils.rm_r(Dir["#{Rails.root}/public/spec"])
  end

  config.include(::CommonHelpers)
  config.include(::DownloadHelpers)
end
