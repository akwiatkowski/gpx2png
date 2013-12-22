require 'gpx2png/calculations/osm_class_methods'

module Gpx2png
  module Calculations
    module OsmInstanceMethods

      TILE_WIDTH = OsmClassMethods::TILE_WIDTH
      TILE_HEIGHT = OsmClassMethods::TILE_WIDTH

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
          puts "Calculated new zoom #{@new_zoom} (was #{@zoom})" if @verbose
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
          puts "Expanding X tiles from both sides #{x_axis_expand_count}" if @verbose
          puts "Expanding Y tiles from both sides #{y_axis_expand_count}" if @verbose
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


    end
  end
end