require_relative 'html2slim/version'
require_relative 'html2slim/converter'

module HTML2Slim
  def self.convert!(input)
    Converter.new(input)
  end
end