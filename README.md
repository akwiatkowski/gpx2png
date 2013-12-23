gpx2png
=======

Render track with OpenStreetMap
---------------------

You can "convert" your tracks to map images using this command.


How to use it
-------------

1. Please check if you have installed RMagick gem.

2. Run command.

  gpx2png -g [input GPX file] -s [image size, format: WIDTHxHEIGHT] -o [output PPNG file]

  Example:

  gpx2png -g spec/fixtures/sample.gpx -s 800x600 -o map.png

3. You can specify zoom.

  gpx2png -g [input GPX file] -z [zoom, best results between 9 and 15, max 18] -o [output PPNG file]

  Example:

  gpx2png -g spec/fixtures/sample.gpx -z 11 -o map.png

4. You can change map provider:

  * OpenStreetMap - defualt
  * UMP - add -u to use [UMP tiles](http://ump.waw.pl/)
  * Cycle - add -u to use [UMP tiles](http://ump.waw.pl/)


Contributing to gpx2png
-------------------------------

[![Flattr this git repo](http://api.flattr.com/button/flattr-badge-large.png)](https://flattr.com/submit/auto?user_id=bobik314&url=https://github.com/akwiatkowski/gpx2png&title=gpx2png&language=en_GB&tags=github&category=software)

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.


Copyright
---------

Copyright (c) 2012-2014 Aleksander Kwiatkowski. See LICENSE.txt for
further details.

