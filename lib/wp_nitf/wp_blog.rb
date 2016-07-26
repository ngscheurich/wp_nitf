module WpNitf
  class WpBlog < Sequel::Model
    def self.blog_ids
      ids = []
      all.each { |blog| ids << blog.blog_id unless blog.blog_id == 1 }
      ids
    end

    def self.blog_name(blog_id)
      prefix = WpBlog.prefix(blog_id)
      query = "select option_value from #{prefix}_options where option_id = 2"
      DB.fetch(query) do |row|
        return row[:option_value]
      end
    end

    def self.blog_id(blog_name)
      blog_ids.each do |blog_id|
        name = blog_name(blog_id)
        return blog_id if name == blog_name
      end
    end

    def self.prefix(blog_id)
      "wp_#{blog_id}"
    end
  end
end
