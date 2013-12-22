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

      def enlarge_border_coords(layer)
        _lat_min = layer.coords.collect { |c| c[:lat] }.min
        _lat_max = layer.coords.collect { |c| c[:lat] }.max
        _lon_min = layer.coords.collect { |c| c[:lon] }.min
        _lon_max = layer.coords.collect { |c| c[:lon] }.max

        @lat_min = _lat_min if @lat_min.nil? or _lat_min < @lat_min
        @lat_max = _lat_max if @lat_max.nil? or _lat_max > @lat_max
        @lon_min = _lon_min if @lon_min.nil? or _lon_min < @lon_min
        @lon_max = _lon_max if @lon_max.nil? or _lon_max > @lon_max
      end

    end
  end
end