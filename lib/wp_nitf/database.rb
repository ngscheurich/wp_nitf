require "sequel"

module WpNitf
  module Database
    def self.connect
      Sequel.mysql("wp_blogs", host: "localhost", user: "root")
    end
  end
end
