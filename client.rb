require 'drb'

STDOUT.sync = true;
exit_requested = false;
Kernel.trap( "INT" ) { exit_requested = true }

IP = "localhost"
PORT = 9000
CONNECTION = "druby://#{IP}:#{PORT}"

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

begin
	DRb.start_service
	remote = DRbObject.new(nil, CONNECTION)
	# puts remote.target_dir
	
rescue
	puts "ERROR: Connection failed"
end
begin
	puts remote.add_links urls_to_download nil
rescue
	puts "ERROR: Remote Method Call didn't worked :("
	puts "INTERNAL ERROR: #{$!}"
end
# STDOUT.flush

# puts remote.add_links(urls_to_download,nil,nil,nil)
# options = {}
# options[:cred],options[:ref],options[:cookie] = nil, nil, nil

# puts remote.add_links(urls_to_download,options)
# puts remote.add_links(["www.wp.pl"],options)