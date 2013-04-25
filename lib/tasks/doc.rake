require "yard"
require "state_machine"
require "yard-state_machine"

namespace :doc do
  desc "Technical documentation"
  YARD::Rake::YardocTask.new("html") do |doc|
    doc.files = Dir["app/helpers/*.rb"] + Dir["app/inputs/*.rb"] + Dir["lib/travel_support_program/*.rb"] +
          Dir["app/models/*.rb"] + %w(db/schema.rb - doc/ABOUT.md doc/USERGUIDE.md LICENSE)
    doc.options += ["-o", "doc/html", "--markup", "markdown", "--tag", "callback", "--plugin", "activerecord"]
  end
end
