#!/usr/bin/env rake
# frozen_string_literal: true

# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.
module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.include TempFixForRakeLastComment

require File.expand_path('config/application', __dir__)

TravelSupport::Application.load_tasks
