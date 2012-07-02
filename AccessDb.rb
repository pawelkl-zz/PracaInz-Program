# require 'rubygems'
require 'mongo'
require 'json'
require 'active_support'

class AccessDb
  def initialize dbname, collection #, username, password
    @dbname = dbname
    @collection = collection
    @conn = Mongo::Connection.new
    @db   = @conn[dbname]
    @coll = @db[collection]
  end

  def upsert_by_id id, json
    @coll.update({ :_id => id }, json, :upsert => true)
  end

  def upsert_by_meta json
    print json
    @coll.update({ :hash_md5 => json["hash_md5"] }, json, :upsert => true)
  end

  def remove json
    if json[:_id].nil?
      then @coll.remove({ :hash_md5 => json[:hash_md5]})
    else
      @coll.remove({:_id => json[:id]})
    end
  end

  def add_info json, param, value
    if json[:_id].nil?
      then @coll.update({ :hash_md5 => json[:hash_md5] }, '$set' => { param => value })
    else
      @coll.update({ :_id => json[:id] }, '$set' => { param => value })
    end
  end

  def remove_info json, param
    if json[:_id].nil?
      then @coll.update({ :hash_md5 => json[:hash_md5] }, '$set' => { param => nil })
    else
      @coll.update({ :_id => json[:id] }, '$set' => { param => nil})
    end
  end

  def find json
    @coll.find_one({:hash_md5 => json[:hash_md5]},{:fields => {:_id=>0}})
  end

  def update query, update
    @coll.find_and_modify(:query => query, :update => update)
  end
end

if __FILE__ == $0
  require 'test/unit'
  require 'active_support/core_ext/hash'
  require 'mongo'
  require 'json'

  class AccessDbTest < Test::Unit::TestCase
    def setup
      @coll = AccessDb.new "meta","meta"
    end

    def teardown
      @coll.remove({:hash_md5 => [:sara,:ania]})
    end

    def test_read
      json = {:hash_md5 => :sara}
      @coll.upsert_by_meta json
      # puts id
      find = @coll.find json
      # assert_equal(json[:hash_md5], find.except!("_id")["hash_md5"])
      assert_equal json[:hash_md5], find["hash_md5"], "json file didn't match input file"
      #find.except!("_id")["hash_md5"])
      # assert_equal(82,id)
    end

    def test_read_with_hash
      json = {:hash_md5 => :lolcats}
      @coll.upsert_by_meta json
      find = @coll.find json
      # json[:_id] = id
      assert_equal json, find, "retrieved json file isn't exactly the same as input json"
    end

    def test_added_info
      json = {:hash_md5 => :ania}
      @coll.upsert_by_meta json
      @coll.add_info(json, :stan, :zajeta)
      find = @coll.find(json)
      assert_equal(json[:stan], find[:stan])
      @coll.remove_info(json, :stan)
      assert_equal(json[:stan], nil)
    end

    def test_delete
      json = {:hash_md5 => :beata}
      @coll.upsert_by_meta json
      @coll.remove({:hash_md5 => :beata})
      find = @coll.find(json)
      assert_equal(nil, find)
    end
  end
end