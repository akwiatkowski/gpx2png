require 'gpx2png/calculations/osm_class_methods'

module Gpx2png
  module Calculations
    module OsmInstanceMethods

      TILE_WIDTH = OsmClassMethods::TILE_WIDTH
      TILE_HEIGHT = OsmClassMethods::TILE_WIDTH

      attr_reader :lat_min, :lat_max, :lon_min, :lon_max
      attr_reader :tile_x_distance, :tile_y_distance
      # points for cropping
      attr_reader :bitmap_point_x_max, :bitmap_point_x_min, :bitmap_point_y_max, :bitmap_point_y_min

      def initial_calculations
        calculate_minmax_latlon

        # auto zoom must be here
        # drawing must fit into fixed resolution
        # map must be bigger than fixed resolution
        if @fixed_width and @fixed_height
          @new_zoom = self.class.calc_zoom(
            @lat_min, @lat_max,
            @lon_min, @lon_max,
            @fixed_width, @fixed_height
          )
          self.class.logger.debug "Calculated new zoom #{@new_zoom.to_s.red} (was #{@zoom.to_s.red})"
          @zoom = @new_zoom
        end

        @border_tiles = [
          self.class.convert(@zoom, [@lat_min, @lon_min]),
          self.class.convert(@zoom, [@lat_max, @lon_max])
        ]

        @tile_x_range = (@border_tiles[0][0])..(@border_tiles[1][0])
        @tile_y_range = (@border_tiles[1][1])..(@border_tiles[0][1])

        # enlarging ranges to fill up map area
        # both sizes are enlarged
        if @fixed_width and @fixed_height
          x_axis_expand_count = ((@fixed_width - (1 + @tile_x_range.max - @tile_x_range.min) * TILE_WIDTH).to_f / (TILE_WIDTH.to_f * 2.0)).ceil
          y_axis_expand_count = ((@fixed_height - (1 + @tile_y_range.max - @tile_y_range.min) * TILE_HEIGHT).to_f / (TILE_HEIGHT.to_f * 2.0)).ceil
          self.class.logger.debug "Expanding #{"X".to_s.blue} tiles from both sides #{x_axis_expand_count.to_s.green}"
          self.class.logger.debug "Expanding #{"Y".to_s.blue} tiles from both sides #{y_axis_expand_count.to_s.green}"
          @tile_x_range = ((@tile_x_range.min - x_axis_expand_count)..(@tile_x_range.max + x_axis_expand_count))
          @tile_y_range = ((@tile_y_range.min - y_axis_expand_count)..(@tile_y_range.max + y_axis_expand_count))
        end

        # new/full image size
        @full_image_x = (1 + @tile_x_range.max - @tile_x_range.min) * TILE_WIDTH
        @full_image_y = (1 + @tile_y_range.max - @tile_y_range.min) * TILE_HEIGHT
        @r.x = @full_image_x
        @r.y = @full_image_y

        if @fixed_width and @fixed_height
          calculate_for_crop_with_auto_zoom
        else
          calculate_for_crop
        end
      end

      # Calculate zoom level
      def auto_zoom_for(x = 0, y = 0)
        # TODO
      end

      # Calculate some numbers for cropping operation
      def calculate_for_crop
        point_min = self.class.point_on_image(@zoom, [@lat_min, @lon_min])
        point_max = self.class.point_on_image(@zoom, [@lat_max, @lon_max])
        @bitmap_point_x_min = (point_min[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_min[:pixel_offset][0]
        @bitmap_point_x_max = (point_max[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_max[:pixel_offset][0]
        @bitmap_point_y_max = (point_min[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_min[:pixel_offset][1]
        @bitmap_point_y_min = (point_max[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_max[:pixel_offset][1]

        @r.set_crop(@bitmap_point_x_min, @bitmap_point_x_max, @bitmap_point_y_min, @bitmap_point_y_max)
      end

      # Calculate some numbers for cropping operation with autozoom
      def calculate_for_crop_with_auto_zoom
        point_min = self.class.point_on_image(@zoom, [@lat_min, @lon_min])
        point_max = self.class.point_on_image(@zoom, [@lat_max, @lon_max])
        @bitmap_point_x_min = (point_min[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_min[:pixel_offset][0]
        @bitmap_point_x_max = (point_max[:osm_title_coord][0] - @tile_x_range.min) * TILE_WIDTH + point_max[:pixel_offset][0]
        @bitmap_point_y_max = (point_min[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_min[:pixel_offset][1]
        @bitmap_point_y_min = (point_max[:osm_title_coord][1] - @tile_y_range.min) * TILE_HEIGHT + point_max[:pixel_offset][1]

        bitmap_x_center = (@bitmap_point_x_min + @bitmap_point_x_max) / 2
        bitmap_y_center = (@bitmap_point_y_min + @bitmap_point_y_max) / 2

        @r.set_crop_fixed(bitmap_x_center, bitmap_y_center, @fixed_width, @fixed_height)
      end

      def expand_map
        # TODO expand min and max ranges
      end

      # Do everything
      def download_and_join_tiles
        self.class.logger.info "Output image dimension #{@full_image_x.to_s.red} x #{@full_image_y.to_s.red}"
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

            self.class.logger.debug "processed #{(x - @tile_x_range.min).to_s.red} x #{(y - @tile_y_range.min).to_s.red} (max #{(@tile_x_range.max - @tile_x_range.min).to_s.yellow} x #{(@tile_y_range.max - @tile_y_range.min).to_s.yellow})"
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


    end
  end
end