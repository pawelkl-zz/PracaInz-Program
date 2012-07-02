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
  options[:directory] = 'c:/temp'
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
  target =  f + :":meta.json".to_s
  if File.exists? target; pp target end
  # puts target
  puts File.open(target,"r").read
end

=begin
if __FILE__ == $0
  require 'test/unit'
  require 'active_support/core_ext/hash'

  class EtlTest < Test::Unit::TestCase
    def setup
      @coll = AccessDb.new "meta","meta"
    end

    def teardown
      @coll.remove({:hash_md5 => [:sara,:ania]})
    end

  end
end
=end
