require File.dirname(__FILE__) + "/../test_helper"

class TestMachineImage < Test::Unit::TestCase
  def setup
    @repo = File.dirname(__FILE__)+'/../fixtures/machine_images'
    @mvi = machine_image_fixture
  end
  
  def test_list
    assert_kind_of Array, MachineImage.list
    assert MachineImage.list(@repo).include?(@mvi.image_id)
  end
  
  def test_find
    assert_match /mvi_\S*/, @mvi.image_id
    assert_equal @mvi.image_id, @mvi.name
    assert_kind_of MachineImage, @mvi
  end
  
  def test_rsync_to
    @mvi.rsync_clone_to(:target=>'/tmp/mv_testing')
    File.exists?("/tmp/mv_testing/#{@mvi.image_id}.xml")
    File.exists?("/tmp/mv_testing/#{@mvi.root_disk_image}")    
  end
  
  def test_rsync_to_custom_image_id
    @mvi.rsync_clone_to(:target=>'/tmp/mv_testing', :image_id=>'custom')
    File.exists?("/tmp/mv_testing/#{@mvi.root_disk_image}")
    File.exists?("/tmp/mv_testing/custom.xml")
  end
  
  def test_read_domain_xml
    assert @mvi.domain_xml.match(/domain/)
    assert @mvi.domain_xml.match(/disk0.qcow2/)
  end
  
  def test_rsync_image
    
  end
  
  def test_description
    @mvi.description "very informative"
    assert_equal "very informative", @mvi.description
  end
  
  def test_parse_xml
    parsed = @mvi.parse_domain_xml
    assert_equal 'disk0.qcow2', parsed[:devices].first[:disk].last[:source].first.file
    assert_equal 'kvm', parsed[:type]
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