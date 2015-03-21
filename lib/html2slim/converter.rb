require_relative 'hpricot_monkeypatches'

module HTML2Slim
  class Converter
    def to_s
      @slim
    end
  end
  class HTMLConverter < Converter
    def initialize(html)
      @slim = Hpricot(html).to_slim
    end
  end
  class ERBConverter < Converter
    def initialize(file)
      # open.read makes it works for files & IO
      erb = File.exists?(file) ? open(file).read : file

      erb.gsub!(/<%(.+?)\s*\{\s*(\|.+?\|)?\s*%>/){ %(<%#{$1} do #{$2}%>) }

      # case, if, for, unless, until, while, and blocks...
      erb.gsub!(/<%(-\s+)?((\s*(case|if|for|unless|until|while) .+?)|.+?do\s*(\|.+?\|)?\s*)-?%>/){ %(<ruby code="#{$2.gsub(/"/, '&quot;')}">) }
      # else
      erb.gsub!(/<%-?\s*else\s*-?%>/, %(</ruby><ruby code="else">))
      # elsif
      erb.gsub!(/<%-?\s*(elsif .+?)\s*-?%>/){ %(</ruby><ruby code="#{$1.gsub(/"/, '&quot;')}">) }
      # when
      erb.gsub!(/<%-?\s*(when .+?)\s*-?%>/){ %(</ruby><ruby code="#{$1.gsub(/"/, '&quot;')}">) }
      erb.gsub!(/<%\s*(end|}|end\s+-)\s*%>/, %(</ruby>))
      erb.gsub!(/<%(.+?)\s*-?%>/m){ %(<ruby code="#{$1.gsub(/"/, '&quot;')}"></ruby>) }
      @slim ||= Hpricot(erb).to_slim
    end
  end
end
