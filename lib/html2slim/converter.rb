require_relative 'hpricot_monkeypatches'
# html = File.read(ARGV[0])
module HTML2Slim
  class Converter
    def initialize(html)
      @slim = Hpricot(html).to_slim
    end
    def to_s
      @slim
    end
  end
end