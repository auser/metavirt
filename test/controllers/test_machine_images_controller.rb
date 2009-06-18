require File.dirname(__FILE__) + "/../test_helper"
require 'rack/test'

class TestMachineImagesController < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    MachineImagesController.new
  end
  
  def setup
    FileUtils.mkdir_p('/tmp/mv_testing')
    @fixture_dir = File.dirname(__FILE__)+'/../fixtures/machine_images'
    @image_id = 'mvi_1df7be00'
    @root_disk_img = Rack::Test::UploadedFile.new("#{@fixture_dir}/#{@image_id}/disk0.qcow2")
  end
  
  def teardown
    FileUtils.rm_rf('/tmp/mv_testing')
  end
  
  def test_new_image
    get('/new')
    assert last_response.ok?
  end

  def test_post

    post('/', :root_disk_image  => @root_disk_img, 
              :arch             => 'i386', 
              :description      => 'notes',
              :repository       => '/tmp/mv_testing'
        )
    assert last_response.ok?
    m_name =  JSON.parse(last_response.body).first
    assert MachineImage.list('/tmp/mv_testing').include?(m_name)
    assert File.exists?("/tmp/mv_testing/#{m_name}/disk0.qcow2")
    assert File.file?("/tmp/mv_testing/#{m_name}/domain.xml")
    assert_match /disk0.qcow2/, open("/tmp/mv_testing/#{m_name}/domain.xml").read
    assert_match /#{m_name}/, open("/tmp/mv_testing/#{m_name}/domain.xml").read
    
    
    get("/#{m_name}")
    assert last_response.ok?
    
  end
  
  
   
end
