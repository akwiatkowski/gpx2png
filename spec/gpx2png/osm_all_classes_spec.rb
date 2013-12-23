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

  begin
    require 'chunky_png'
    @chunky = true
  rescue LoadError
    puts "chunky_png not available"
    @chunky = false
  end

  if @rmagick
    it "should create using GPX file with all classes" do
      g = GpxUtils::TrackImporter.new
      g.add_file(File.join('spec', 'fixtures', 'sample.gpx'))

      klasses = [
        Gpx2png::Osm,
        Gpx2png::Ump,
        Gpx2png::OpenCycle,
        Gpx2png::Transport,
        Gpx2png::Landscape,
        Gpx2png::Outdoors
      ]

      klasses.each do |k|
        k.simulate_download = false

        e = k.new
        e.renderer = :rmagick
        e.renderer_options = { aa: true, opacity: 0.5, crop_enabled: true }
        e.coords = g.coords
        #e.zoom = 10
        e.fixed_size(600, 600)

        file_name = "klass_#{k.to_s.gsub(/\W/, "_")}"

        e.save("samples/tmp/#{file_name}.png")
        e.destroy

        k.simulate_download = true
      end
    end
  end
end
