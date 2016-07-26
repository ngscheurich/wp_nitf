module WpNitf
  class SectionMap
    def self.blog_to_tag(name)
      map[name] || "baton_rouge/news"
    end

    def self.map
      {
        "Black and Gold" => "new_orleans/sports/saints",
        "Tiger Tracks" => "baton_rouge/sports/lsu",
        "Line Drives" => "baton_rouge/sports/lsu",
        "Full Court Press" => "baton_rouge/sports/lsu",
        "Politics Blog" => "baton_rouge/news/politics",
        "City Hall Buzz" => "baton_rouge/news",
        "BR prep sports" => "baton_rouge/sports/high_schools",
        "NO prep sports" => "new_orleans/sports/high_schools",
        "Southern Jaguars Nation" => "baton_rouge/sports/southern",
        "After Dark" => "acadiana/entertainment_life"
      }
    end
  end
end
