require "fix_state_machine_yard" if Rails.env.development?

namespace :doc do
  desc "Technical documentation"
  YARD::Rake::YardocTask.new("html") do |doc|
    doc.options += ["-o", "doc/html"]

    doc.after = Proc.new {
      images_path = Rails.root.join('app', 'assets', 'images')
      %w(TravelSponsorship Shipment Reimbursement).each do |klass|
        if File.exists?(file = Rails.root.join('doc', 'html', "#{klass}_state.png"))
          cp file, images_path
        end
      end
    }
  end
end
