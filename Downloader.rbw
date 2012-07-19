#!/usr/bin/env ruby
# require 'rubygems'
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

# class Download
#   include DataMapper::Resource
#   property :id, Serial
#   property :url, String, :required => true, :length => 1024
# end

STDOUT.sync = true;
exit_requested = false;
Kernel.trap( "INT" ) { exit_requested = true }

options = {}

optparse = OlptionParser.new do |opts|
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
  puts "Options: #{options}"
  puts "ARGV: #{ARGV}"
    urls_to_download = [
    'http://www.shapings.com/images/detailed/2/CVNESPT.jpg',
    # 'http://www.opensubtitles.org/addons/avi/breakdance.avi', # 8e245d9679d31e12
    # # 'http://www.opensubtitles.org/addons/avi/dummy.rar', # 61f7751fc2a72bfb
    'http://static.skynetblogs.be/media/163667/1714742799.2.jpg',
    # 'http://imgur.com/NMHpw.jpg',
    # 'http://i.imgur.com/USdtc.jpg',
    # 'http://i.imgur.com/Dexpm.jpg',
    # 'http://www.shapings.com/images/detailed/2/CVNESPT.jpg',
    # 'http://static3.blip.pl/user_generated/update_pictures/2639011.jpg',
    # 'http://3.asset.soup.io/asset/3187/8131_3a06.jpeg',
    # 'http://e.asset.soup.io/asset/3182/1470_9f47_500.jpeg',
    'http://static3.blip.pl/user_generated/update_pictures/2638909.jpg'
  ]
  options[:destination] = 'c:/temp'
  # ARGV= urls_to_download
  options[:url] = urls_to_download
end

=begin GUI
  class MinimalApp < App
     def on_init
      Frame.new(nil, -1, "Simple downloader",nil,Size.new(600,480)).show()
     end
  end

  class MyFrame < Frame
    def initialize()
      super(nil, -1, 'My Frame Title')
      @my_panel = Panel.new(self)
      @my_label = StaticText.new(@mby_panel, -1, 'My Label Text', DEFAULT_POSITION, DEFAULT_SIZE, ALIGN_CENTER)
      @my_textbox = TextCtrl.new(@my_panel, -1, 'Default Textbox Value')
      @my_combo = ComboBox.new(@my_panel, -1, 'Default Combo Text',   DEFAULT_POSITION, DEFAULT_SIZE, ['Item 1', 'Item 2', 'Item 3'])
      @my_button = Button.new(@my_panel, -1, 'My Button Text')
    end
  end

  MinimalApp.new.main_loop

  exit!
=end

class Downloader
  def initialize(directory,db,collection)
    @PASS=nil
    @COOKIE=nil
    @filename=nil
    @full_file_location = nil
    @target_dir = directory
    File.exists? @target_dir # File.directory? @target_dir
    @c = Curl::Easy.new
    curl_setup
    @mongo = AccessDb.new db, collection
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

  def add_links(url_array,cred=nil,ref=nil,cookie=nil)
    link_setup(cred,ref,cookie)
    url_array.each do |single_url|
      @c.url=single_url
      @filename = single_url.split(/\?/).first.split(/\//).last
      @save_location = @target_dir + '\\' + @filename
      @c.perform
      File.open(@save_location,"wb").write @c.body_str

      json = parse_link_info single_url
      @mongo.upsert_by_meta json
      File.open(@save_location + :":meta.json".to_s,"w").write json
    end
  end
end

manager = Downloader.new options[:destination],"meta","meta"
manager.add_links options[:url].nil? ? ARGV : options[:url]