require 'spec_helper'
require 'gpx2png/osm'

describe Gpx2png::Osm do
  begin
    require 'RMagick'
    @rmagick = true
  rescue LoadError
    puts "RMagick not available"
    @rmagick = false
  end

  if @rmagick
    it "should create simple 2-layer map" do
      e = Gpx2png::Osm.new
      layer = e.add_layer({ color: '#0000FF' })
      layer.add(50.0, 20.0)
      layer.add(51.0, 20.0)
      layer.add(51.0, 21.0)
      layer.add(50.0, 21.0)

      layer_b = e.add_layer({ color: '#FF3300' })
      layer_b.add(50.1, 20.1)
      layer_b.add(51.1, 20.1)
      layer_b.add(51.1, 21.1)
      layer_b.add(50.1, 21.1)

      e.save('samples/tmp/png_multilayer1_simple.png')
      e.destroy
    end
  end

end
