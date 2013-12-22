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

    # if true it will not download tiles
    attr_accessor :simulate_download

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



    attr_reader :lat_min, :lat_max, :lon_min, :lon_max
    attr_reader :tile_x_distance, :tile_y_distance
    # points for cropping
    attr_reader :bitmap_point_x_max, :bitmap_point_x_min, :bitmap_point_y_max, :bitmap_point_y_min

    # Do everything
    def download_and_join_tiles
      puts "Output image dimension #{@full_image_x}x#{@full_image_y}" if @verbose
      @r.new_image

      # {:x, :y, :blob}
      @images = Array.new


      @tile_x_range.each do |x|
        @tile_y_range.each do |y|
          url = self.class.url(@zoom, [x, y])

          # blob time
          unless simulate_download?
            uri = URI.parse(url)
            response = Net::HTTP.get_response(uri)
            blob = response.body
          else
            blob = @r.blank_tile(TILE_WIDTH, TILE_HEIGHT, x+y)
          end

          @r.add_tile(
            blob,
            (x - @tile_x_range.min) * TILE_WIDTH,
            (y - @tile_y_range.min) * TILE_HEIGHT
          )

          @images << {
            url: url,
            x: x,
            y: y
          }

          puts "processed #{x - @tile_x_range.min}x#{y - @tile_y_range.min} (max #{@tile_x_range.max - @tile_x_range.min}x#{@tile_y_range.max - @tile_y_range.min})" if @verbose
        end
      end

      # sweet, image is joined

      # min/max points used for cropping
      @bitmap_point_x_max = (@full_image_x / 2).round
      @bitmap_point_x_min = (@full_image_x / 2).round
      @bitmap_point_y_max = (@full_image_y / 2).round
      @bitmap_point_y_min = (@full_image_y / 2).round

      # add all coords to the map
      @layers.each do |layer|
        _coords = layer.coords
        (1..._coords.size).each do |i|

          lat_from = _coords[i-1][:lat]
          lon_from = _coords[i-1][:lon]

          lat_to = _coords[i][:lat]
          lon_to = _coords[i][:lon]

          point_from = self.class.point_on_image(@zoom, [lat_from, lon_from])
          point_to = self.class.point_on_image(@zoom, [lat_to, lon_to])
          # { osm_title_coord: osm_tile_coord, pixel_offset: [x, y] }

          # first point
          bitmap_xa = (point_from[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_from[:pixel_offset][0]
          bitmap_ya = (point_from[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_from[:pixel_offset][1]
          bitmap_xb = (point_to[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_to[:pixel_offset][0]
          bitmap_yb = (point_to[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_to[:pixel_offset][1]

          @r.line(
            bitmap_xa, bitmap_ya,
            bitmap_xb, bitmap_yb
          )
        end
      end

      # add points
      @markers.each do |point|
        lat = point[:lat]
        lon = point[:lon]

        p = self.class.point_on_image(@zoom, [lat, lon])
        bitmap_x = (p[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + p[:pixel_offset][0]
        bitmap_y = (p[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + p[:pixel_offset][1]

        point[:x] = bitmap_x
        point[:y] = bitmap_y

        @r.markers << point
      end
    end



    def self.licence_string
      "Map data OpenStreetMap (CC-by-SA 2.0)"
    end

    def destroy
      @r.destroy
      puts "Image destroyed" if @verbose
    end

  end
end
