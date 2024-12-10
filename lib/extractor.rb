require "pry"
require "nokogiri"

class Extractor
  PARENT_CLASS_TO_EXTRACT = "appbar"
  CHILD_CLASS_TO_EXTRACT  = "klitem"

  def initialize(file:)
    @file = file
  end

  def extract
    child_elements.map { |element| Extractable.new(element).serialized }
  end

  private

  def child_elements
    parent_element.css("a[class*=#{CHILD_CLASS_TO_EXTRACT}]")
  end

  def parent_element
    html.css("div[class*=#{PARENT_CLASS_TO_EXTRACT}]")
  end

  def html
    Nokogiri.HTML(File.open(@file), nil, "UTF-8")
  end
end

class Extractable
  BASE_URL = "https://www.google.com"

  def initialize(extractable)
    @extractable = extractable
  end

  def serialized
    serialized = 
      {
        "name":  name,
        "link":  BASE_URL + link,
        "image": image
      }
    
    has_extensions? ? serialized.merge({ "extensions": extensions }) : serialized
  end

  private

  def name
    @extractable["aria-label"]
  end

  def link
    @extractable.attribute("href").value
  end

  def image
    return if @extractable.css("img").first.nil?

    @extractable.css("img").first["src"]
  end

  def extensions
    @extensions ||= begin
      current = @extractable

      while current.children.any?
        current = current.children.last
      end

      if current.text == name
        []
      else
        current.text
      end
    end
  end
  
  def has_extensions?
    extensions.size.positive?
  end
end
