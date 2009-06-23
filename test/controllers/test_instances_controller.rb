require File.dirname(__FILE__) + "/../test_helper"
require 'rack/test'

class TestInstancesController < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    MetaVirt::InstancesController.new
  end
  
  def setup
    @instance = fake_instance
  end
  
  def test_should_get_root
    assert get('/').ok?
  end
  
  def test_should_get_instace_id
    get("/bogus")
    assert !last_response.ok?
    get("/#{@instance.instance_id}")
  end
  
  def test_should_get_new_image_page
     # assert get("/")
   end
  # def test_should_post_a_new_image
  #   assert put("/machine_images/", :xml_definition=>"/tmp/file.xml")
  # end 
end