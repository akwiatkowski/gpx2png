module Gpx2png
  module Calculations
    module BaseInstanceMethods
      def calculate_minmax_latlon
        @layers.each do |l|
          enlarge_border_coords(l)
        end
        # when no coords specified
        @lat_min ||= -0.01
        @lat_max ||= 0.01
        @lon_min ||= -0.01
        @lon_max ||= 0.01
      end
    end
  end
end