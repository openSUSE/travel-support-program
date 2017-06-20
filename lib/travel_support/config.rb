#
# Module for application-wide code
#
module TravelSupport
  #
  # Facility class for system configuration
  #
  class Config
    @@config = {}

    # Loads the relevant section of the config file (config/site.yml)
    def self.init(group)
      @@config = YAML.load_file(Rails.root.join('config', 'site.yml'))[group]
    rescue
      puts $ERROR_INFO
    end

    # Returns the value of a given setting
    def self.setting(*keys)
      keys.inject(@@config) { |val, k| val.is_a?(Hash) ? val[k.to_s] : nil }
    end
  end
end
