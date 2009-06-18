require File.dirname(__FILE__) + "/test_helper"
require 'rack/test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    MetaVirt::MetadataServer.new
  end
  
  def test_should_get_root
    get("/")
    assert last_response.ok?
  end
  
  def test_run_instance
    get('/run_instance')
    
  end
  
end