require "thor"

module WpNitf
  class Cli < Thor
    option :blog_id, type: :numeric, aliases: "-i",
           desc: "ID of blog to export from"
    option :blog_name, type: :numeric, aliases: "-b",
           desc: "Name of blog to export from"
    option :num, type: :numeric, aliases: "-n",
           desc: "Number of posts to export"
    option :destination, type: :string, aliases: "-d",
           desc: "Path to export XML files to"
    desc "export [options]", "Export post(s) by blog ID or name"
    def export
      WpNitf.convert(blog_id, options[:num])
    end

    option :num, type: :numeric, aliases: "-n",
           desc: "Number of posts to export"
    desc "export_all [options]", "Export post(s) from all blogs"
    def export_all
      WpNitf::WpBlog.blog_ids.each do |blog_id|
        WpNitf.convert(blog_id, options[:num])
      end
    end

    private

    def blog_id
      if options[:blog_id]
        return options[:blog_id]
      elsif options[:blog_name]
        return WpNitf::WpBlog.blog_id(options[:blog_name])
      else
        raise ArgumentError, "Either `--blog-id` or `--blog-name` must be specified"
      end
    end
  end
end
