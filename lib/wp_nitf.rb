require "sequel"
require "wp_nitf/cli"
require "wp_nitf/database"
require "wp_nitf/logger"
require "wp_nitf/nitf_post"
require "wp_nitf/section_map"
require "wp_nitf/text_filters"
require "wp_nitf/version"

module WpNitf
  DB = Database.connect
  DB.convert_invalid_date_time = nil
  require "wp_nitf/wp_blog"
  require "wp_nitf/wp_site"
  require "wp_nitf/wp_user"

  XML_DIR = File.dirname(__FILE__) + "/../xml"

  def self.convert(blog_id, num = nil)
    posts = WpSite.blog_posts(blog_id, num)
    posts.each { |post| NitfPost.new(post, blog_id).save }
  end

  def self.convert_by_name(blog_name, num= nil)
    convert(WpBlog.blog_id(blog_name), num)
  end

  def self.convert_all(num = nil)
    WpBlog.blog_ids.each { |id| convert(id, num) }
  end
end
