require 'optparse'
require 'pp'
require 'find'

STDOUT.sync = true; exit_requested = false; Kernel.trap( "INT" ) { exit_requested = true }

options = {}

optparse = OptionParser.new do|opts|
  opts.banner = "Usage: Downloader.rbw [options] url1 url2 ..."

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end

  options[:directory] = []
    opts.on( '-d', '--directory dir', "List of urls" ) do |u|
    options[:directory] = u
  end
end

optparse.parse!

if __FILE__ == $0
  options[:directory] = 'c:/foobar2000'
  pp "Options:", options
  pp "ARGV:", ARGV
end

# search_dir = options[:directory].to_s + '\**\*'
# puts search_dir

# Dir[options[:directory]].each{|file|
# 	# do  something
# 	# sprawdzenie czy plik posiada metadane
# 	if
# 		then
	# end
# }

Find.find(options[:directory]) do |f| 
  File.exists? f:":meta.json"
end

