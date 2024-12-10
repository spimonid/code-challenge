require 'extractor'
require 'pry'
require 'json'

describe "SerpApi Carousel Challenge" do
  before :all do
    @extracted_paintings = Extractor.new(file: "files/van-gogh-paintings.html").extract
  end

  attr_reader :extracted_paintings

  describe "extracted Van Gogh paintings .html equals provided expectation" do
    before :all do
      @expected_array = JSON.load(File.read("files/expected-array.json"))["artworks"]
    end

    attr_reader :expected_array

    it "encodes painting names correctly" do
      name = "Café Terrace at Night"
      expect(extracted_paintings.map { |painting| painting[:name] }).to include(name)
    end

    it "is the same size" do
      expect(extracted_paintings.size).to eq(expected_array.size)
    end

    it "has all the same painting names" do
      expect(expected_array.map { |painting| painting["name"] }).to match_array(
        extracted_paintings.map { |painting| painting[:name] })
    end

    it "has the same number of paintings missing images" do
      expect(expected_array.count { |painting| painting.has_key?("image") && painting["image"].nil? }).to eq(
        extracted_paintings.count { |painting| painting.has_key?(:image) && painting[:image].nil? })
    end

    it "has the same number of paintings missing extensions" do
      expect(expected_array.count { |painting| !painting.keys.include?("extensions")}).to eq(
        extracted_paintings.count { |painting| !painting.keys.include?(:extensions)})
    end
  end

  describe "data structure" do
    before :all do
      @extracted_pistons = Extractor.new(file: "files/detroit-pistons-players.html").extract
      @extracted_cities  = Extractor.new(file: "files/cities-in-michigan.html").extract
    end

    attr_reader :extracted_pistons, :extracted_cities

    it "is an array of hashes" do
      [extracted_paintings, extracted_pistons, extracted_cities].each do |extracted|
        expect(extracted.is_a?(Array)).to be true
        expect(extracted.all? { |element| element.is_a?(Hash) }).to be true
      end
    end

    describe "when extracting from the old carousel" do
      it "has the correct keys" do
        expect(extracted_paintings.flat_map(&:keys).uniq).to include(:name, :image, :link, :extensions)
      end
    end

    describe "when extracting from the new carousel" do
      it "has the correct keys" do
        expect(extracted_pistons.flat_map(&:keys).uniq).to include(:name, :image, :link, :extensions)
        expect(extracted_cities.flat_map(&:keys).uniq).to include(:name, :image, :link)
      end
    end
  end
end