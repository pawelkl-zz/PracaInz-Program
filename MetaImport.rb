require 'optparse'
require 'pp'
require 'find'
require 'json'

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



class MetaImport
  attr_reader :path
  def initialize(path)
    @path = path
  end
  # def ==()
  # end
  def import
    Find.find(@path) do |f|
      target =  f + :":meta.json".to_s
      if File.exists? target; pp target end
      # puts target
      data = File.open(target).read
      puts JSON.parse(data)
      # puts JSON.pretty_generate(json)
      # puts json[:link_filename_requested]
      json
    end
  end
end

if __FILE__ == $0
  options[:directory] = 'c:/temp'
  pp "Options:", options
  pp "ARGV:", ARGV
end

MetaImport.new(options[:directory]).import

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
