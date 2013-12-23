require 'colorize'
require 'logger'
require 'gpx2png/layer'
require 'gpx2png/calculations/base_class_methods'
require 'gpx2png/calculations/base_instance_methods'

module Gpx2png
  class Base
    extend Calculations::BaseClassMethods
    include Calculations::BaseInstanceMethods

    def initialize
      @layers = Array.new
      _layer = Layer.new
      _layer.parent = self
      @layers << _layer
      @single_layer = true

      @zoom = 9

      self.class.logger.debug("Init, default zoom #{@zoom.to_s.green}")
    end

    def add_layer(_layer_options)
      if @single_layer
        self.class.logger.debug("Created #{"first".to_s.red} layer")
        # turn off single layer version
        @single_layer = false
        # set layer options for first layer and return it
        _layer = @layers.first
        _layer.options = _layer_options
        return _layer
      else
        # create new layer with options, add to list and return
        _layer = Layer.new
        _layer.parent = self
        _layer.options = _layer_options
        @layers << _layer
        self.class.logger.debug("Created layer, count: #{@layers.size.to_s.red}")
        return _layer
      end
    end

    def add(lat, lon)
      if @single_layer
        # add coord to first layer
        _layer = @layers.first
        _layer.add(lat, lon)
      else
        # I'm afraid Dave I can't do that
        self.class.logger.fatal("After you've added first layer you can use coords only from layers")
        raise StandardError
      end
    end

    def coords=(_coords)
      if @single_layer
        # add coord to first layer
        _layer = @layers.first
        _layer.coords = _coords
      else
        # I'm afraid Dave I can't do that
        self.class.fatal("After you've added first layer you can use coords only from layers")
        raise StandardError
      end
    end

    def color(_color)
      if @single_layer
        # add coord to first layer
        _layer = @layers.first
        _layer.color = _color
      else
        # I'm afraid Dave I can't do that
        self.class.fatal("After you've added first layer you have to use layers")
        raise StandardError
      end
    end

    # Create image with fixed size
    def fixed_size(_width, _height)
      @fixed_width = _width
      @fixed_height = _height
      self.class.debug("Map image fixed dimension set #{@fixed_width.to_s.red} x #{@fixed_height.to_s.red}")
      true
    end

    def zoom=(_zoom)
      self.class.debug("Map zoom set #{_zoom.to_s.red}")
      @zoom = _zoom
    end

    def zoom
      @zoom
    end

    attr_accessor :layers

    # Simulate download of tiles
    attr_accessor :simulate_download

    def self.simulate_download=(b)
      logger.debug("Simulate tiles download for class #{self.to_s.blue}") if b
      @@simulate_download = b
    end

    def simulate_download?
      return true if true == self.simulate_download or (defined? @@simulate_download and true == @@simulate_download)
    end

    def destroy
      @r.destroy
      self.class.logger.debug "Image destroyed"
    end

    def self.logger=(_logger)
      @@logger = _logger
    end

    def self.logger
      @@logger = Logger.new(STDOUT) unless defined? @@logger
      return @@logger
    end

  end
end