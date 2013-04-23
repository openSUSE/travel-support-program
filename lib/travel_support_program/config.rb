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

    def self.setting(*keys)
      keys.inject(@@config) {|val, k| val.kind_of?(Hash) ? val[k.to_s] : nil}
    end
  end
end
