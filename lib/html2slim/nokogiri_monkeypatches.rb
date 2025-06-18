require 'nokogiri'

class Nokogiri::XML::Text
  def to_slim(lvl = 0)
    str = escape(content)
    return nil if str.strip.empty?

    ('  ' * lvl) + %(| #{str.gsub(/\s+/, ' ')})
  end

  private

  def escape(str)
    str.gsub!('&', '&amp;')
    str.gsub!('©', '&copy;')
    str.gsub!("\u00A0", '&nbsp;')
    str.gsub!('»', '&raquo;')
    str.gsub!('<', '&lt;')
    str.gsub!('>', '&gt;')
    str
  end
end

class Nokogiri::XML::DTD
  def to_slim(_lvl = 0)
    if to_xml.include?('xml')
      to_xml.include?('iso-8859-1') ? 'doctype xml ISO-88591' : 'doctype xml'
    elsif to_xml.include?('XHTML') || to_xml.include?('HTML 4.01')
      available_versions = Regexp.union ['Basic', '1.1', 'strict', 'Frameset', 'Mobile', 'Transitional']
      version = to_xml.match(available_versions).to_s.downcase
      "doctype #{version}"
    else
      'doctype html'
    end
  end
end

class Nokogiri::XML::Element
  BLANK_RE = /\A[[:space:]]*\z/.freeze

  def slim(lvl = 0)
    r = '  ' * lvl

    return r + slim_ruby_code(r) if ruby?

    r += name unless skip_tag_name?
    r += slim_id
    r += slim_class
    r += slim_attributes
    r
  end

  def to_slim(lvl = 0)
    if children.count.positive?
      %(#{slim(lvl)}\n#{children.filter_map { |c| c.to_slim(lvl + 1) }.join("\n")})
    else
      slim(lvl)
    end
  end

  private

  def slim_ruby_code(r)
    (code.strip[0] == '=' ? '' : '- ') + code.strip.gsub('\\n', "\n#{r}- ")
  end

  def code
    attributes['code'].to_s
  end

  def skip_tag_name?
    div? && (has_id? || has_class?)
  end

  def slim_id
    has_id? ? "##{self['id']}" : ''
  end

  def slim_class
    has_class? ? ".#{self['class'].to_s.strip.split(/\s+/).join('.')}" : ''
  end

  def slim_attributes
    remove_attribute('class')
    remove_attribute('id')
    has_attributes? ? "[#{attributes_as_html.to_s.strip}]" : ''
  end

  def has_attributes? # rubocop:disable Naming/PredicateName
    attributes.to_hash.any?
  end

  def has_id? # rubocop:disable Naming/PredicateName
    has_attribute?('id') && !(BLANK_RE === self['id'])
  end

  def has_class? # rubocop:disable Naming/PredicateName
    has_attribute?('class') && !(BLANK_RE === self['class'])
  end

  def ruby?
    name == 'ruby'
  end

  def div?
    name == 'div'
  end

  def html_quote(str)
    "\"#{str.gsub('"', '\\"')}\""
  end

  def attributes_as_html
    attributes.map do |aname, aval|
      " #{aname}" + (aval ? "=#{html_quote aval.to_s}" : '')
    end.join
  end
end

class Nokogiri::XML::DocumentFragment
  def to_slim
    if children.count.positive?
      children.filter_map(&:to_slim).join("\n")
    else
      ''
    end
  end
end

class Nokogiri::XML::Document
  def to_slim
    if children.count.positive?
      children.filter_map(&:to_slim).join("\n")
    else
      ''
    end
  end
end

class Nokogiri::XML::Comment
  def to_slim(lvl = 0)
    r = '  ' * lvl

    # Render as a Slim comment, multiline if necessary
    str = content.strip
    return nil if str.empty?

    if str.include?("\n")
      "#{r}/!\n#{r}  " + str.gsub("\n", "\n#{r}  ")
    else
      "#{r}/! #{str}"
    end
  end
end
