require 'fileutils'
require 'ostruct'

class Renamer
  attr_accessor :path, :syntax, :recursive, :preview, :fetch_tvdb
  
  def initialize(path=".")
    @recursive = true
    @dest_path = ''
    @path = File.expand_path(path)
    @fetch_tvdb = true
    @api = Tvdb.new 
  end
  
  def start
    process
  end
  
  private
  def process(path=@path)
    abort("Path '#{path}' does not exist") unless File.exists? path
    
    if File.directory? path      
      puts "Processing directory: " + path
      puts ""
      Dir.chdir(path) { process_cwd }
    else
      Dir.chdir(File.dirname(path)) do
        process_file(File.basename(path))
      end
    end
  end
  
  def process_file(file)

    series, episode = get_show_info(file)

    unless episode.nil? || episode.season_number == 0

      if self.syntax.nil?
        self.syntax = "%S - %0sx%0e - %T"
      end

      new_name = self.syntax \
        .gsub("%S",series.name) \
        .gsub("%XS",series.name.gsub(/\s/, '.')) \
        .gsub("%0s",episode.season_number.to_s.rjust(2,'0')) \
        .gsub("%s",episode.season_number.to_s) \
        .gsub("%0e",episode.number.to_s.rjust(2,'0')) \
        .gsub("%e",episode.number.to_s) \
        .gsub("%T",episode.name)

      new_name = new_name.strip + "." + file.split('.').last
      
      unless file == new_name
        puts "#{file} -> #{new_name}"
        FileUtils.mv file, new_name unless preview
      end
    end
  end

  def process_cwd
    Dir.entries('.').each do |entry|
      unless entry =~ /^\./
        if recursive && File.directory?(entry)
          process(File.expand_path(File.join(Dir.pwd, entry)))
        else
          process_file(entry) if VALID_VIDEO_TYPES.include? entry.split('.').last.downcase
        end
      end
    end
  end

  def get_show_info(file)
    parsed_series, parsed_season, parsed_number = *TVParser.parse(file)
    
    if fetch_tvdb
      episode = get_episode(parsed_series, parsed_season, parsed_number)
      series = get_series(series)
    else
      episode = OpenStruct.new(:season_number => parsed_season, :number => parsed_number, :name => '')
      series = OpenStruct.new(:name => parsed_series)
    end

    [series, episode]
  end
  
  def get_episode(series, season, number)
    if series.is_a? Fixnum
      @api.get_episode(series, season, number)
    else
      if series = get_series(series)
        series.episode(season, number)
      else
        nil
      end
    end
  end
  
  def get_series(name)
    if not @series or @series[name].nil?    
      series = @api.search(name + " ") # space at end fixes weird TvDB issue
      @series ||= {}
      @series[name] = series
    end
    
    @series[name]
  end
end
