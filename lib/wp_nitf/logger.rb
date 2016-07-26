require "logger"

module WpNitf
  LOGGER = Logger.new(STDOUT)

  def self.log(blog_id, msg, method = "info")
    LOGGER.send(:"#{method}", "[#{blog_id}] #{msg}")
  end
end
