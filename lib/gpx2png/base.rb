require 'gpx2png/layer'

#$:.unshift(File.dirname(__FILE__))

module Gpx2png
  class Base

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

    attr_accessor :zoom, :color, :layers

    # Some math stuff
    def self.rad2deg(rad)
      return rad * 180.0 / Math::PI
    end

    def self.deg2rad(deg)
      return deg * Math::PI / 180.0
    end

  end
end