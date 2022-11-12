if Rails.root.join('.git').exist?
  git = Git.open(Rails.root)
  version = git.describe
  File.write(Rails.root.join('VERSION'), version)
end

module TravelSupport
  # If we are outside of the version control, this file needs to be created
  # manually
  VERSION = File.read(Rails.root.join('VERSION')).strip
end
