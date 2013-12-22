require 'gpx2png/base'
require 'net/http'
require "uri"
require 'gpx2png/calculations/osm_class_methods'
require 'gpx2png/calculations/osm_instance_methods'

module Gpx2png
  class OsmBase < Base
    extend Calculations::OsmClassMethods
    include Calculations::OsmInstanceMethods

    TILE_WIDTH = Calculations::OsmClassMethods::TILE_WIDTH
    TILE_HEIGHT = Calculations::OsmClassMethods::TILE_HEIGHT

    # Convert latlon deg to OSM tile url
    # TODO add algorithm to choose from diff. servers
    def self.url_convert(zoom, coord, server = 'b.')
      x, y = convert(zoom, coord)
      url(zoom, [x, y], server)
    end

    # Convert OSM tile coords to url
    def self.url(zoom, coord, server = 'b.')
      x, y = coord
      url = "http://#{server}tile.openstreetmap.org\/#{zoom}\/#{x}\/#{y}.png"
      return url
    end

    def self.licence_string
      "Map data OpenStreetMap (CC-by-SA 2.0)"
    end



  end
end
