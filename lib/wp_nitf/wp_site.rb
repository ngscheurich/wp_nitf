module WpNitf
  class WpSite
    def self.blog_posts(blog_id = 2, num = nil)
      table = WpBlog.prefix(blog_id) + "_posts"
      conditions = "post_parent = 0"
      limit = num.nil? ? "" : " LIMIT #{num}"
      query = "SELECT * FROM #{table} WHERE #{conditions}#{limit}"
      begin
        DB.fetch(query)
      rescue Sequel::Error => e
        log(blog_id, "Couldn't get posts. #{e.message}", "error")
      end
    end

    def all_posts(num = nil)
      posts = []
      WpBlog.blog_ids.each { |id| posts << blog_posts(id, num) }
      posts
    end
  end
end
