require 'rubygems'
require 'nokogiri'

module Readability
  class Document

    def initialize(input)
      @html = Nokogiri::HTML(input)
    end

    def content

      # Get all parent elements containing a <p> tag
      @parents = @html.css("p").map { |p| p.parent }.compact.uniq

      sanitize(@parents.map { |p| [p, score(p)] }.max { |a, b| a[1] <=> b[1] }[0])

    end

    def encoding
      @html.meta_encoding
    end

    def score(parent)
      s = 0

      # Adjust score based on parent's "class" attribute
      s -= 50 if parent[:class] =~ /(comment|meta|footer|footnote)/i
      s += 25 if parent[:class] =~ /((^|\s)(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)(\s|$))/i

      # Adjust score based on parent id
      s -= 50 if parent[:id] =~ /(comment|meta|footer|footnote)/i
      s += 25 if parent[:id] =~ /^(post|hentry|entry[-]?(content|text|body)?|article[-]?(content|text|body)?)$/i

      # Adjust score based on # of <p> elements inside parent
      s += parent.css("p").size

      # Adjust score based on # of commas inside parent
      s += parent.text.count ","

      s
    end

    def sanitize(node)

      # Get rid of divs full of non-text items
      node.css("div").each do |el| 
        counts = Hash[ %w[p img li a embed].map { |kind| [kind, el.css(kind)] } ]
        counts.reject! {|k,v| v.nil? }
        compare_to_p = counts.dup
        p = if p_css = compare_to_p.delete("p")
          p_css.size
        else
          0
        end

        embeds = if embed_css = compare_to_p.delete("embed")
                   embed_css.size
                 else
                   0
                 end
        if (el.text.count(",") < 10) 
          p_there = compare_to_p.values.inject(false) do |result, current| 
            result || current.size > p 
          end
          el.remove if embeds > 0

        end
    end

    # We'll sanitize all elements using a whitelist
    whitelist = %w[table td tr th tbody h1 h2 h3 h4 h5 h6 div pre code blockquote p li a ol span b i del sup sub ]
    attribute_whitelist = %w{href src}
    # Use a hash for speed (don't want to make a million calls to include?)
    whitelist = Hash[ whitelist.zip([true] * whitelist.size) ]

    ([node] + node.css("*")).each do |el| 

      # If element is in whitelist, delete all its attributes
      if whitelist[el.node_name]
        el.attributes.each { |a, x| el.delete(a) unless attribute_whitelist.include?(a) }

        # Otherwise, replace the element with its contents
      else
        el.swap(el.text)
      end

    end

    # Get rid of duplicate whitespace
    node.to_html.gsub(/[\r\n\f]+/, "\n" ).gsub(/[\t ]+/, " ").gsub(/&nbsp;/, " ")
  end

end
end
