# require 'rubygems'
require 'mongo'
require 'json'

class AccessDb
	def initialize dbname, collection #, username, password
		# @db = Connection.new.db('meta');
		# @coll = db.collection('meta')

		# @conn = new Mongo(:pool_size => 5, :timeout => 5)
		# @db = conn.getDb dbname
		# db.auth username, password
		@dbname = dbname
		@collection = collection
		@conn = Mongo::Connection.new
		@db   = @conn[dbname]
		@coll = @db[collection]
	end
	def upsert_by_id id, json
		@coll.update({ :_id => id }, json, :upsert => true) # upsert!
	end
	def upsert_by_meta json
		puts json
		@coll.update({ :hash => json[:hash] }, json, :upsert => true, :return_key => false)
	end
	# def insert json
	# 	# id = @coll.insert(json)
	# 	# TODO:
	# 	# odczytanie z mety hasha i probowanie znalezienie w bazie tego elementu i dopiero wtedy dodanie poprzez uzycie upserta (3 arg true)
	# 	# this = @coll.find({ :hash => json[:hash] })
	# 	# update({ :hash => hash}, @collection, true) # upsert!
	# 	update_by_id({ :hash => json[:hash]}, @collection, true) # upsert!
	# 	# @coll.update({ :_id => id }, '$set' => { db_id => id })
	# end
	def delete id
		@coll.remove({ :_id => id})
	end
	def add id, param, value
		@coll.update({ :_id => id }, '$set' => { param => value })
		# @coll.find_and_modify(:_ibd => id)
	end
	# def fetch
	# 	@coll.find_one
	# end
	def find json
		@coll.find_one(:hash => json[:hash])
	end
end


=begin
@conn = Mongo::Connection.new
@db   = @conn['sample-db']
@coll = @db['test']

@coll.remove
3.times do |i|
  @coll.insert({'a' => i+1})
end

puts "There are #{@coll.count} records. Here they are:"
@coll.find.each { |doc| puts doc.inspect }
=end

if __FILE__ == $0
  require 'test/unit'
  require 'active_support/core_ext/hash'

  class AccessDbTest < Test::Unit::TestCase
  	def setup
  		@coll = AccessDb.new "meta","meta"
  	end
  	def teardown
  	end
  	def test_read
    	json = {:hash => "sara"}
    	@coll.upsert_by_meta json
    	find = @coll.find(json)
    	# puts find.except!("_id")
    	# puts find.convert_fields_for_query {:hash}
      assert_equal(json[:hash], find.except!("_id")["hash"])
    end

    # def test_compute_hash_large_file
    #   assert_equal("61f7751fc2a72bfb", MovieHasher::compute_hash('dummy.bin'))
    # end

    # def test_jpeg
    #   assert_equal("bed5a0ecf41d0d96", MovieHasher::compute_hash('2638909.jpg')) # => bed5a0ecf41d0d96, zle 8228bb57b5b72510
    # end
  end
end