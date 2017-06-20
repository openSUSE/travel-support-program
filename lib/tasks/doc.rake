require 'fix_state_machine_yard' if Rails.env.development?

namespace :doc do
  desc 'Technical documentation'
  YARD::Rake::YardocTask.new('html') do |doc|
    doc.options += ['-o', 'doc/html']

    doc.after = proc {
      images_path = Rails.root.join('app', 'assets', 'images')
      %w[TravelSponsorship Shipment Reimbursement].each do |klass|
        if File.exist?(file = Rails.root.join('doc', 'html', "#{klass}_state.png"))
          cp file, images_path
        end
      end
    }
  end
end
