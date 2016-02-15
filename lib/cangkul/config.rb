require "yaml"

module Cangkul
  class Config
    def self.server
      @@config ||= YAML.load_file(File.expand_path("../../config/cangkul.yaml", __FILE__))
      @@config["server"]
    end

    def self.client
      @@config ||= YAML.load_file(File.expand_path("../../config/cangkul.yaml", __FILE__))
      @@config["client"]
    end
  end
end
