module Gpx2png
  class Layer
    def initialize
      @coords = Array.new
      @options = Hash.new
    end

    attr_accessor :options, :coords, :parent

    def coords=(_coords)
      logger.debug("Set #{_coords.size.to_s.red} for layer #{self.index.to_s.green}")
      @coords = _coords
    end

    def coords
      @coords
    end

    # Number of this layer
    def index
      if @parent
        return parent.layers.index(self)
      end
      return nil
    end

    def logger
      @parent.class.logger
    end

    def add(lat, lon)
      logger.debug("Added coord #{lat.to_s.red},#{lon.to_s.red} for layer #{self.index.to_s.green}, count #{(@coords.size + 1).to_s.blue}")
      @coords << { lat: lat, lon: lon }
    end
  end
end