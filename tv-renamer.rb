$:.unshift File.dirname(__FILE__)

require 'lib/tvdb/tvdb'
require 'lib/tvparser'
require 'lib/tvrenamer'

VALID_VIDEO_TYPES = %w{avi mkv m2v mpg mpeg mov ogm wmv mp4 srt}
QUALITIES = %w{HDTV 720P 1080i Bluray}

renamer = Renamer.new(ARGV.shift || ".")
renamer.syntax = "%XS.S%0sE%0e"
# renamer.fetch_tvdb = false # Doesn't hit tvdb.com for show info.
# renamer.preview = false # Won't rename :)
# renamer.recursive = false

## Moves show into destination_path/Show Name/ Season XX
## Must be full path i.e. '/Users/you/wherever or C:\wherever
# renamer.destination_path = ''

renamer.start
