require_relative 'html2slim/version'
require_relative 'html2slim/converter'

module HTML2Slim
  def self.convert!(input, format=:html)
    if format.to_s == "html"
      HTMLConverter.new(input)
    else
      ERBConverter.new(input)
    end
  end
end