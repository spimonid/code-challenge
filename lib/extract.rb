require "json"
require_relative "extractor.rb"

result = Extractor.new(file: ARGV[0]).extract

puts JSON.pretty_generate("artworks": result)