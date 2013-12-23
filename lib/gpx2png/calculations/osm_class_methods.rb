module Gpx2png
  module Calculations
    module OsmClassMethods

      TILE_WIDTH = 256
      TILE_HEIGHT = 256

      # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y
      # Convert latlon deg to OSM tile coords
      def convert(zoom, coord)
        lat_deg, lon_deg = coord
        lat_rad = deg2rad(lat_deg)
        x = (((lon_deg + 180) / 360) * (2 ** zoom)).floor
        y = ((1 - Math.log(Math.tan(lat_rad) + 1 / Math.cos(lat_rad)) / Math::PI) /2 * (2 ** zoom)).floor

        logger.debug "Converted #{lat_deg.to_s.green},#{lat_deg.to_s.green} to [#{x.to_s.red},#{y.to_s.red}]"

        return [x, y]
      end

      # Convert OSM tile coords to latlon deg in top-left corner
      def reverse_convert(zoom, coord)
        x, y = coord
        n = 2 ** zoom
        lon_deg = x.to_f / n.to_f * 360.0 - 180.0
        lat_deg = rad2deg(Math.atan(Math.sinh(Math::PI * (1.to_f - 2.to_f * y.to_f / n.to_f))))

        logger.debug "Reverse converted [#{x.to_s.red},#{y.to_s.red}] to #{lat_deg.to_s.green},#{lat_deg.to_s.green}"

        return [lat_deg, lon_deg]
      end

      # Lazy calc proper zoom for drawing
      def calc_zoom(lat_min, lat_max, lon_min, lon_max, width, height)
        # because I'm lazy! :] and math is not my best side

        last_zoom = 2
        (5..18).each do |zoom|
          # calculate drawing tile size and pixel size
          tile_min = point_on_absolute_image(zoom, [lat_min, lon_min])
          tile_max = point_on_absolute_image(zoom, [lat_max, lon_max])
          current_pixel_x_distance = tile_max[0] - tile_min[0]
          current_pixel_y_distance = tile_min[1] - tile_max[1]
          if current_pixel_x_distance > width or current_pixel_y_distance > height
            logger.debug "Calculated best zoom #{last_zoom.to_s.red}"
            return last_zoom
          end
          last_zoom = zoom
        end
        return 18
      end

      # Convert latlon deg coords to image point (x,y) and OSM tile coord
      # return where you should put point on tile
      def point_on_image(zoom, geo_coord)
        osm_tile_coord = convert(zoom, geo_coord)
        top_left_corner = reverse_convert(zoom, osm_tile_coord)
        bottom_right_corner = reverse_convert(zoom, [
          osm_tile_coord[0] + 1, osm_tile_coord[1] + 1
        ])

        # some line math: y = ax + b

        x_geo = geo_coord[1]
        # offset
        x_offset = x_geo - top_left_corner[1]
        # scale
        x_distance = (bottom_right_corner[1] - top_left_corner[1])
        x = (TILE_WIDTH.to_f * (x_offset / x_distance)).round

        y_geo = geo_coord[0]
        # offset
        y_offset = y_geo - top_left_corner[0]
        # scale
        y_distance = (bottom_right_corner[0] - top_left_corner[0])
        y = (TILE_HEIGHT.to_f * (y_offset / y_distance)).round

        logger.debug("Point on image: zoom #{zoom.to_s.green}, coord #{geo_coord[0].to_s.green},#{geo_coord[1].to_s.green} => [#{x.to_s.red}, #{y.to_s.red}]")

        return { osm_title_coord: osm_tile_coord, pixel_offset: [x, y] }
      end

      # Useful for calculating distance on output image
      # It is not position on output image because we don't know tile coords
      # For upper-left tile
      def point_on_absolute_image(zoom, geo_coord)
        _p = point_on_image(zoom, geo_coord)
        _x = _p[:osm_title_coord][0] * TILE_WIDTH + _p[:pixel_offset][0]
        _y = _p[:osm_title_coord][1] * TILE_WIDTH + _p[:pixel_offset][1]

        logger.debug("Point on abs. image: zoom #{zoom.to_s.green}, coord #{geo_coord[0].to_s.green},#{geo_coord[1].to_s.green} => [#{_x.to_s.red}, #{_y.to_s.red}]")

        return [_x, _y]
      end


    end
  end
end