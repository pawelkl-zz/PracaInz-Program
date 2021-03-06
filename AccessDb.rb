# require 'rubygems'
require 'mongo'
require 'json'
# require 'mash'
# require 'active_support'

class AccessDb
  def initialize dbname, collection #, username, password
    @dbname = dbname
    @collection = collection
    # begin
      @conn = Mongo::Connection.new
      @db   = @conn[dbname]
      @coll = @db[collection]
    # rescue
      # puts "ERROR: MongoDB server is down"
      # @enb = false
    # end
  end

  def upsert_by_id id, json
    # json = JSON.parse! json
    @coll.update({ :_id => id }, json, :upsert => true)
  end

  def upsert_by_meta json
    # json = JSON.parse! json
    @coll.update(
      { "hash_md5" => json["hash_md5"] },
      json,
      :upsert => true
      )
  end

  def remove json
    # json = JSON.parse! json
    if json[:_id].nil?
      then @coll.remove({ "hash_md5" => json[:hash_md5]})
    else
      @coll.remove({:_id => json[:id]})
    end
  end

  def add_info json, param, value
    # json = JSON.parse! json
    if json[:_id].nil?
      then @coll.update(
        { "hash_md5" => json[:hash_md5] },
        '$set' => { param => value }
        )
    else
      @coll.update({ :_id => json[:id] }, '$set' => { param => value })
    end
  end

  def remove_info json, param
    # json = JSON.parse! json
    if json[:_id].nil?
      then @coll.update(
        { "hash_md5" => json[:hash_md5] },
        '$set' => { param => nil }
        )
    else
      @coll.update({ :_id => json[:id] }, '$set' => { param => nil})
    end
  end

  def find json
    # json = JSON.parse! json
    @coll.find_one(
      {"hash_md5" => json[:hash_md5]},
      {:fields => {:_id=>0}}
      )
    # find.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
  end

  def update query, update
    # json = JSON.parse! json
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
      @coll.remove({"hash_md5" => ["beata","ania","some_hash"]})
    end

    def test_add
      json = {:hash_md5 => "some_hash"}
      @coll.upsert_by_meta json
      find = @coll.find json
      # json[:_id] = id
      find = find.each_with_object({}){|(k,v), h| h[k.to_sym] = v}
      assert_equal json, find, "retrieved json file isn't exactly the same as input json"
    end

    def test_added_info
      json = {:hash_md5 => :ania}
      @coll.upsert_by_meta json
      @coll.add_info(json, :stan, :zajeta)
      find = @coll.find json
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