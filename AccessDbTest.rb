require 'test/unit'
require 'active_support/core_ext/hash'
require 'mongo'
require 'json'
require 'AccessDb'

class AccessDbTest < Test::Unit::TestCase
def setup
  @coll = AccessDb.new "meta","meta"
end

def teardown
  @coll.remove({:hash_md5 => [:sara,:ania]})
end

def test_read
  json = {:hash_md5 => :sara}
  id = @coll.upsert_by_meta json
    # puts id
    find = @coll.find json
    # assert_equal(json[:hash_md5], find.except!("_id")["hash_md5"])
    assert_equal json[:hash_md5], find["hash_md5"], "json file didn't match input file"
    #find.except!("_id")["hash_md5"])
    # assert_equal(82,id)
  end

  def test_read_with_hash
    json = {:hash_md5 => :lolcats}
    id = @coll.upsert_by_meta json
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