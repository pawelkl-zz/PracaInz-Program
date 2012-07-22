#!/usr/bin/env ruby
# require 'rubygems'
require 'drb'
require 'curb'
require 'yaml'
# require 'json'
require 'json/pure'
require 'digest/md5'
load 'D:\Dropbox\#code\PracaInz-Program\MovieHasher.rb' # load 'moviehasher.rb'
load 'D:\Dropbox\#code\PracaInz-Program\AccessDb.rb'
# require 'wx'
# include Wx
require 'optparse'
require 'pp'
require 'mash'
# require 'active_support'

IP = "localhost"
PORT = 9000
CONNECTION = "druby://#{IP}:#{PORT}"
ADS = false
$SAFE = 1

STDOUT.sync = true;
exit_requested = false;
Kernel.trap( "INT" ) { exit_requested = true }

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: Downloader.rbw [options] url1 url2 ..."

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end

  options[:url] = []
    opts.on( '-u', '--url a,b,c', Array, "List of urls" ) do |u|
    options[:url] = u
  end

  options[:cookie] = ""
    opts.on( '-c', '--cookie COOKIE', "" ) do |c|
    options[:cookie] = c
  end

  options[:cred] = ""
    opts.on( '-t', '--cred USER:PASSWORD', "" ) do |c|
    options[:cred] = c
  end

  options[:ref] = ""
    opts.on( '-r', '--ref REF-LINK', "" ) do |c|
    options[:ref] = c
  end

  options[:file] = ""
    opts.on( '-f', '--file FILE', "" ) do |c|
    options[:file] = c
  end

  options[:destination] = ""
    opts.on( '-d', '--destination DESTINATION-FOLDER', "" ) do |c|
    options[:destination] = c
  end
end

optparse.parse!

if __FILE__ == $0
  # puts "Options: #{options}"
  # puts "ARGV: #{ARGV}"
  options[:destination] = 'c:/temp'
end

# class BlankSlate
#   # safe_methods = %w{__send__ __id__ inspect respond_to? to_s}
#   safe_methods = %w{object_id __send__ __id__ inspect respond_to? to_s}
#   (instance_methods - safe_methods).each do |method|
#     undef_method method
#   end
# end

class Downloader #< BlankSlate
	include DRb::DRbUndumped
  attr_reader :target_dir

  def initialize(directory,db,collection)
    @PASS=nil
    @COOKIE=nil
    @filename=nil
    @full_file_location = nil
    @target_dir = directory
    File.exists? @target_dir # File.directory? @target_dir
    @c = Curl::Easy.new
    curl_setup
    begin
    	@mongo = AccessDb.new db, collection
    	@mongoenb = true
    rescue
    	@mongoenb = false
    	puts "WARNING: MongoDB server is down"
    end
  end

  def curl_setup
    @c.dns_cache_timeout = 8
    @c.fetch_file_time = true
    @c.verbose = false
    @c.follow_location = true
    @c.on_success {|easy| puts "success #{@filename}"}
    # @c.on_body{|data| responses[url] << data; data.size }
    @c.header_in_body = false
  end

  def link_setup(cred,ref,cookie)
    # @c.username = user
    # @c.password = pass
    @c.userpwd = cred
    @c.autoreferer = true
    @c.connect_timeout = 15
    @c.cookiefile = cookie
    # @c.cookiejar = cookiejar
    # @c.cookies=COOKIES # NAME=CONTENTS;
  end

  def parse_link_info(url)
    json = {}
    # json = ActiveSupport::HashWithIndifferentAccess.new

    json[:link_requested] = url
    if @c.last_effective_url != url
      then json[:link_final] = @c.last_effective_url end

    json[:link_filename_requested] =  @filename
    @final_filename = @c.last_effective_url.split(/\?/).first.split(/\//).last
    if @final_filename != @filename
      then json[:link_filename_delivered] = @final_filename end

    json[:link_filetime] = Time.at(@c.file_time).utc.to_s

    json[:content_lenght] = @c.downloaded_content_length
    json[:content_type] = @c.content_type

    @hash = MovieHasher::compute_hash(@save_location)
    @hash = MovieHasher::compute_hash(@save_location)

    if !@hash.nil?
      then json[:hash_bigfile] = @hash end

    json[:hash_md5] = Digest::MD5.hexdigest(File.read(@save_location))
    # JSON.generate json
    json
  end

  def add_links(url_array,options) #cred=nil,ref=nil,cookie=nil)
    link_setup(options[:cred],options[:ref],options[:cookie])
    result = {}
    url_array.each do |single_url|
      @c.url=single_url
      @filename = single_url.split(/\?/).first.split(/\//).last
      @save_location = @target_dir + '\\' + @filename
      @c.perform
      File.open(@save_location,"wb").write @c.body_str
      json = parse_link_info single_url
      result[single_url] = json[:content_lenght]
      if @mongoenb == true then @mongo.upsert_by_meta json end
      if ADS == true
    	then
    		File.open(@save_location + :":meta.json".to_s,"w").write json
    	else
    		File.open(@save_location + @filename + ".meta","w").write json
	  	end
    end
    puts result
  end
end

manager = Downloader.new options[:destination],"meta","meta"
# manager.add_links options[:url].nil? ? ARGV : options[:url]

begin
	DRb.start_service(CONNECTION, manager)
	puts "INFO: Ready!"
  # Drb.stop_service
	DRb.thread.join
rescue
	puts "ERROR: Server already running on port #{PORT}"
end