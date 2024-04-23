require_relative 'nokogiri_monkeypatches'

module HTML2Slim
  class Converter
    def initialize(html)
      nokogiri = html[..1] == '<!' ? Nokogiri.parse(html) : Nokogiri::HTML.fragment(html)
      @slim = nokogiri.to_slim
    end

    def to_s
      @slim
    end
  end

  class HTMLConverter < Converter
    def initialize(file)
      html = file.read
      super(html)
    end
  end

  class ERBConverter < Converter
    def initialize(file)
      erb = file.read

      erb.gsub!(/<%(.+?)\s*\{\s*(\|.+?\|)?\s*%>/) { %(<%#{$1} do #{$2}%>) }
      # case, if, for, unless, until, while, and blocks...
      erb.gsub!(/<%(-\s+)?((\s*(case|if|for|unless|until|while) .+?)|.+?do\s*(\|.+?\|)?\s*)-?%>/) do
        %(<ruby code="#{escape($2)}">)
      end
      # else
      erb.gsub!(/<%-?\s*else\s*-?%>/, %(</ruby><ruby code="else">))
      # elsif
      erb.gsub!(/<%-?\s*(elsif .+?)\s*-?%>/) { %(</ruby><ruby code="#{escape($1)}">) }
      # when
      erb.gsub!(/<%-?\s*(when .+?)\s*-?%>/) { %(</ruby><ruby code="#{escape($1)}">) }
      erb.gsub!(/<%\s*(end|}|end\s+-)\s*%>/, %(</ruby>))
      erb.gsub!(/<%-?\n?(.+?)\s*-?%>/m) { %(<ruby code="#{escape($1)}"></ruby>) }

      super(erb)
    end

    private

    def escape(str)
      str.gsub!('&', '&amp;')
      str.gsub!('"', '&quot;')
      str.gsub!("\n", '\n')
      str.gsub!('<', '&lt;')
      str
    end
  end
end
