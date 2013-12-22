require 'gpx2png/layer'
require 'gpx2png/calculations/base_class_methods'
require 'gpx2png/calculations/base_instance_methods'

module Gpx2png
  class Base
    extend Calculations::BaseClassMethods
    include Calculations::BaseInstanceMethods

    def initialize
      @layers = Array.new
      @layers << Layer.new
      @single_layer = true

      @zoom = 9
      @verbose = true
    end

    def add_layer(_layer_options)
      if @single_layer
        # turn off single layer version
        @single_layer = false
        # set layer options for first layer and return it
        _layer = @layers.first
        _layer.options = _layer_options
        return _layer
      else
        # create new layer with options, add to list and return
        _layer = Layer.new
        _layer.options = _layer_options
        @layers << _layer
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
        raise StandardError
      end
    end

    # Create image with fixed size
    def fixed_size(_width, _height)
      @fixed_width = _width
      @fixed_height = _height
    end

    attr_accessor :zoom, :color, :layers

    def self.simulate_download=(b)
      @@simulate_download = b
    end

    def simulate_download?
      return true if true == self.simulate_download or (defined? @@simulate_download and true == @@simulate_download)
    end

    def enlarge_border_coords(layer)
      _lat_min = layer.coords.collect { |c| c[:lat] }.min
      _lat_max = layer.coords.collect { |c| c[:lat] }.max
      _lon_min = layer.coords.collect { |c| c[:lon] }.min
      _lon_max = layer.coords.collect { |c| c[:lon] }.max

      @lat_min = _lat_min if @lat_min.nil? or _lat_min < @lat_min
      @lat_max = _lat_max if @lat_max.nil? or _lat_max > @lat_max
      @lon_min = _lon_min if @lon_min.nil? or _lon_min < @lon_min
      @lon_max = _lon_max if @lon_max.nil? or _lon_max > @lon_max
    end

  end
end