require 'hpricot'

class Hpricot::BogusETag
  def to_slim(lvl=0)
    nil
  end
end

class Hpricot::Text
  def to_slim(lvl=0)
    if to_s.strip.empty?
      nil
    else
      ('  ' * lvl) + %(| #{to_s.gsub(/\s+/, ' ')})
    end
  end
end

class Hpricot::Comment
  def to_slim(lvl=0)
    # For SHTML <!--#include virtual="foo.html" -->
    if self.content =~ /include (file|virtual)="(.+)"/
      ('  ' * lvl) + "= render '#{$~[2]}'"
    else
      nil
    end
  end
end

class Hpricot::DocType
  def to_slim(lvl=0)
    'doctype'
  end
end

class Hpricot::Elem
  def slim(lvl=0)
    r = ('  ' * lvl)
    r += self.name unless self.name == 'div' and (self.has_attribute?('id') || self.has_attribute?('class'))
    r += "##{self['id']}" if self.has_attribute?('id')
    self.remove_attribute('id')    
    r += ".#{self['class'].split(/\s+/).join('.')}" if self.has_attribute?('class')
    self.remove_attribute('class')
    r += "[#{attributes_as_html.to_s.strip}]" unless attributes_as_html.to_s.strip.empty?
    r
  end
  def to_slim(lvl=0)
    if respond_to?(:children) and children
      return %(#{self.slim(lvl)}\n#{children.map { |x| x.to_slim(lvl+1) }.select{|e| !e.nil? }.join("\n")})
    else
      self.slim(lvl)
    end
  end
end

class Hpricot::Doc
  def to_slim
    if respond_to?(:children) and children
      children.map { |x| x.to_slim }.select{|e| !e.nil? }.join("\n")
    else
      ''
    end
  end
end