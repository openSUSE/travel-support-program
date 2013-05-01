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
  images_path = Rails.root.join('app', 'assets', 'images')
  if File.exists?(file = Rails.root.join('doc', 'html', 'Request_state.png'))
    cp file, images_path
  end
  if File.exists?(file = Rails.root.join('doc', 'html', 'Reimbursement_state.png'))
    cp file, images_path
  end
end
