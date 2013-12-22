module Gpx2png
  class Layer
    def initialize
      @coords = Array.new
      @options = Hash.new
    end

    attr_accessor :options, :coords

    def add(lat, lon)
      @coords << { lat: lat, lon: lon }
    end
  end
end