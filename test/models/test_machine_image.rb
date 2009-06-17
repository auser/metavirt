require File.dirname(__FILE__) + "/../test_helper"

class TestMachineImage < Test::Unit::TestCase
  def setup
    FileUtils.mkdir_p('/tmp/mv_testing')
    MachineImage.stubs(:repository).returns('/tmp/mv_testing')
    File.open('/tmp/mv_testing/mvi_fake', 'w'){|f| f<< "fake. This should be a tarball"}
    @mvi = MachineImage.find("mvi_fake")
  end
  
  def teardown
    # File.rm_dir('/tmp/mv_testing')
  end
  
  def test_list
    assert_kind_of Array, MachineImage.list
    assert MachineImage.list.include? 'mvi_fake'
  end
  
  def test_find
    assert_equal 'mvi_fake', @mvi.image_id
    assert_equal @mvi.image_id, @mvi.name
    assert_kind_of MachineImage, @mvi
  end
  
  def test_rsync_image
    @mvi.rsync_to('/tmp/mv_testing')
    p ``
  end
  
  
  # def test_should_be_able_to_create_new_domain_xml_from_image
  # end
  # 
  # def test_should_copy_image_to_instance_run_space
  # end
  # 
  # def test_should_run_copy_of_image
  #   jaunty = MachineImage.create(:name=>'jaunty19', :root_disk_image=>'/tmp/jaunyt.qcow', :definition=>File.read('/tmp/jaunty.xml'))
  #   Instance.run(:image_id=>'jaunty19').should do |instance|
  #     copy jaunty.root_disk_image to instance.working_dir
  #     create a new instance
  #     create a new instance.id.xml
  #     define a new domain thru virsh define instance.id.xml
  #     instance.should be_sshable
  #     jaunty.destroy.should terminate image
  #   end
  # end
  
  

end