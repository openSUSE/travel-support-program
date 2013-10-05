require "fix_state_machine_yard"

namespace :doc do
  desc "Technical documentation"
  YARD::Rake::YardocTask.new("html") do |doc|
    doc.options += ["-o", "doc/html"]

    doc.after = Proc.new {
      images_path = Rails.root.join('app', 'assets', 'images')
      if File.exists?(file = Rails.root.join('doc', 'html', 'Request_state.png'))
        cp file, images_path
      end
      if File.exists?(file = Rails.root.join('doc', 'html', 'Reimbursement_state.png'))
        cp file, images_path
      end
    }
  end
end
