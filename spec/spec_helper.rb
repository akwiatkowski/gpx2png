require 'simplecov'
SimpleCov.start if ENV["COVERAGE"]

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'gpx2png'

# Simulate download using blank tiles
Gpx2png::Osm.simulate_download = true
Gpx2png::Ump.simulate_download = true

# logger
require 'logger'
logger = Logger.new(STDOUT)
logger.level = Logger::DEBUG
Gpx2png::Osm.logger = logger
Gpx2png::Ump.logger = logger

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|

end
