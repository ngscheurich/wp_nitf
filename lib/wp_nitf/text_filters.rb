module WpNitf
  module TextFilters
    def self.apply_filters(text, filters)
      filters.each do |filter|
        klass = Object.const_get("WpNitf::TextFilters::#{filter}")
        text = klass.filter(text)
      end
      text
    rescue StandardError
      "No filter named #{filter}"
    end

    class Filter
      def self.filter
        raise "Abstract method called"
      end
    end

    class RemoveCaptions < Filter
      def self.filter(text)
        text = text.gsub(/\[caption[^\]]*\]/, "")
        text.gsub(%r{\[/caption\]}, "")
      end
    end

    class Upcase < Filter
      def self.filter(text)
        text.upcase
      end
    end
  end
end
