module TravelSupportProgram
  class Config
    @@config = {}

    def self.init(group)
      begin
        @@config = YAML.load_file(Rails.root.join("config", "site.yml"))[group]
      rescue
        puts $!
      end
    end

    def self.setting(key)
      @@config[key.to_s]
    end
  end
end
