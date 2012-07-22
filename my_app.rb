require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/base'

class MyApp < Sinatra::Base
	set :static, true
	set :public_folder, File.dirname(__FILE__) + '/public'

	get '/about' do
		'(c) 2012 Pawel Klosiewicz'
	end

  get '/' do
    'Hello World!'
  end

  # post ''/
end

MyApp.run!