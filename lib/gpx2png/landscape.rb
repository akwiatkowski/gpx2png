require 'rubygems'
require 'gpx2png/osm'

module Gpx2png
  class Landscape < Osm

    # Convert OSM/UMP tile coords to url
    def self.url(zoom, coord, server = '3.')
      x, y = coord
      url = "http://tile.thunderforest.com/landscape/#{zoom}/#{x}/#{y}.png"
      return url
    end

    def self.licence_string
      "All maps copyright Thunderforest.com and OpenStreetMap contributors"
    end

  end
end