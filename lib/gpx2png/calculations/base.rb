module Gpx2png
  module Calculations
    module Base
      # Some math stuff
      def rad2deg(rad)
        return rad * 180.0 / Math::PI
      end

      def deg2rad(deg)
        return deg * Math::PI / 180.0
      end

    end
  end
end