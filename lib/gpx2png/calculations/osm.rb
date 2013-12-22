module Gpx2png
  module Calculations
    module Osm
      # http://wiki.openstreetmap.org/wiki/Slippy_map_tilenames#X_and_Y
      # Convert latlon deg to OSM tile coords
      def convert(zoom, coord)
        lat_deg, lon_deg = coord
        lat_rad = deg2rad(lat_deg)
        x = (((lon_deg + 180) / 360) * (2 ** zoom)).floor
        y = ((1 - Math.log(Math.tan(lat_rad) + 1 / Math.cos(lat_rad)) / Math::PI) /2 * (2 ** zoom)).floor

        return [x, y]
      end
    end
  end
end