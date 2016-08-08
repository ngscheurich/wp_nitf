require "digest/bubblebabble"
require "nokogiri"

module WpNitf
  class NitfPost
    def initialize(post, blog_id, dirname = XML_DIR)
      @post = post
      @photos = []
      text = WpNitf::TextFilters::RemoveCaptions.filter(@post[:post_content])
      @text = Nokogiri::HTML(text)
      @blog_id = blog_id
      @dirname = dirname

      @doc = Nokogiri::XML::Builder.new(encoding: "UTF-8")

      extract_photos
      build
    end

    def save
      file_path = File.join(@dirname, filename)
      File.open(file_path, "w") { |file| file.write(@doc.to_xml) }
    end

    private

    def extract_photos
      imgs = @text.css("img")
      imgs.each do |img|
        @photos << {
          caption: photo_caption(img),
          source: photo_source(img)
        }
        clean_up(img)
      end
    end

    def build
      @doc.nitf do |xml|
        nitf_head
        nitf_body
      end
    end

    def photo_caption(img)
      attrs = img.attributes

      if attrs["title"] && attrs["title"].value != ""
        attrs["title"].value
      elsif attrs["alt"] && attrs["alt"].value != ""
        attrs["alt"].value
      else
        nil
      end
    end

    def photo_source(img)
      src = img.attributes["src"].value
      old_path = %r{blogs.theadvocate.com/.*/files}
      new_path = "ve.theadvocate.com/files/blogs.dir/#{@blog_id}/files"
      src.sub(old_path, new_path)
    end

    def clean_up(img)
      if img.parent.name = "a"
        img.parent.remove
      else
        img.remove
      end
    end

    def nitf_head
      @doc.head do
        @doc.docdata do
          @doc.classifier(type: "tncms:asset", value: "asset")
        end
        @doc.send(:"doc-id", "id-string" => pretty_url)
        @doc.pubdata(type: "web", "position.section" => section[@blog_id])
        @doc.send(:"date.release", norm: @post[:post_date])
      end
    end

    def nitf_body
      @doc.body do
        nitf_body_head
        nitf_body_content
      end
    end

    def nitf_body_head
      @doc.send(:"body.head") do
        @doc.hedline { @doc.hl1(@post[:post_title]) }
        nitf_byline
      end
    end

    def nitf_byline
      user = WpUser.first(ID: @post[:post_author])
      byline = user.nil? ? "" : email_byline(user)
      @doc.byline { @doc.<< byline }
    end

    def email_byline(user)
      "<a href=\"#{user.user_email}\">#{user.user_nicename}</a>"
    end

    def nitf_body_content
      @doc.send(:"body.content") do
        nitf_photos
        nitf_body_text
      end
    end

    def nitf_photos
      @photos.each_with_index do |photo, i|
        @doc.media(:"media-type" => "image") do
          @doc.send(:"media-metadata", name: "id", value: photo_id(i))
          @doc.send(:"media-reference", source: photo[:source])
          unless photo[:caption].nil?
            @doc.send(:"media-caption") do
              @doc.<< "<p>#{photo[:caption].gsub(/&#151;/, '&mdash;')}</p>"
            end
          end
        end
      end
    end

    def photo_id(i)
      pretty_url + "[photo-#{i}]"
    end

    def nitf_body_text
      html = autop(@text.css("body").inner_html)
      @doc.p { @doc.cdata html.gsub("<p></p>", "").gsub("<p><p>", "<p>") }
    end

    def autop(str)
      html = ""
      lines = str.lines.reject { |l| l == "\r\n" }
      lines.each { |l| html << "<p>#{l.to_s.gsub('\r\n', '')}</p>" }
      html
    end

    def filename
      title = @post[:post_title] + (Time.now.to_f * 1000).to_i.to_s
      Digest::SHA1.bubblebabble(title) + ".xml"
    end

    def section
      {
        2 => "baton_rouge/sports/lsu",
        3 => "baton_rouge/sports/lsu",
        4 => "new_orleans/sports/saints",
        5 => "baton_rouge/news/politics",
        6 => "baton_rouge/sports/lsu",
        27 => "baton_rouge/sports/high_schools",
        9 => "baton_rouge/sports/southern",
        26 => "baton_rouge/sports/lsu",
        24 => "baton_rouge/entertainment_life",
        23 => "baton_rouge/news/politics",
        17 => "baton_rouge/sports",
        18 => "new_orleans/sports/high_schools",
        19 => "acadiana/entertainment_life",
        20 => "baton_rouge/opinion/stephanie_grace",
        21 => "baton_rouge/opinion/walt_handelsman",
        22 => "baton_rouge/news",
        29 => "acadiana/sports/ul_lafayette",
        30 => "baton_rouge/news",
        31 => "new_orleans/news/crime_police"
      }
    end

    def pretty_url
      ymd = @post[:post_date].strftime("%Y/%m/%d")
      @post[:guid].split("?")[0] + "#{ymd}/#{@post[:post_name]}"
    end
  end
end
