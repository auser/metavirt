require File.dirname(__FILE__) + "/../test_helper"

class TestInstance < Test::Unit::TestCase
  def setup
    @inst = Instance.create({ 
      :authorized_keys => 'ssh-rsa AAAAB3NzaAAABIwA...',
      :keypair_name => 'id_stuff',
      :image_id => 'ami-8b30d5e2',
      :remoter_base => 'vmrun',
      :created_at => Time.now
     })
  end
  
  def test_should_be_able_to_create
    assert @inst.created_at.nil? == false
  end
  
  def test_remoter_base
    assert @inst.remoter_base == 'vmrun'
    assert @inst.provider == ::PoolParty::Remote::Vmrun
  end
  
  def test_safe_params
    params= Instance.safe_params(:boddingtons=>'yummy', :public_ip=>'76.4.4.4')
    assert !params.keys.include?(:boddingtons)
    assert_equal '76.4.4.4', params[:public_ip]
  end
  
  def test_safe_create
    i=Instance.safe_create({:bad=>'hacked', :image_id=>'fred', :public_key=>'sshkeypub'})
    assert i.image_id = 'fred'
    assert i.created_at.nil? == false
    assert_equal i.authorized_keys, 'sshkeypub'
    assert_raises NoMethodError do i.bad end
  end
  
  def test_to_json
    parsed = JSON.parse(@inst.to_json).symbolize_keys!
    assert_equal parsed.size, @inst.values.size
    assert_equal parsed, @inst.to_hash
    @inst.values.each do |k,v|
      next if k.to_s.scan('_at').size>0
      #parsed[k] = Time.parse(parsed[k])
      assert_equal(parsed[k], v)
    end
  end
  
  def test_options
    i=Instance.create(:remoter_base_options=>{:things=>[1,2,'wow']}.to_yaml)
    assert_equal i.options, {:things=>[1,2,'wow']}
  end
  
  def test_start
    @inst.stubs(:provider).returns(MockRemoter.new)
    launched = @inst.start!
    assert launched.status == 'booting'
    assert_equal launched.instance_id, @inst.instance_id
  end
    
  def test_parse_ifconfig
    ifconfig_string = %q{
eth0      Link encap:Ethernet  HWaddr 00:0c:29:f5:d1:9f  
          inet addr:192.168.248.133  Bcast:192.168.248.255  Mask:255.255.255.0
          inet6 addr: fe80::20c:29ff:fef5:d19f/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:2674 errors:0 dropped:0 overruns:0 frame:0
          TX packets:1860 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:1644612 (1.6 MB)  TX bytes:234972 (234.9 KB)
          Interrupt:19 Base address:0x2000 

lo        Link encap:Local Loopback  
          inet addr:127.0.0.1  Mask:255.0.0.0
          inet6 addr: ::1/128 Scope:Host
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:0 errors:0 dropped:0 overruns:0 frame:0
          TX packets:0 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0 
          RX bytes:0 (0.0 B)  TX bytes:0 (0.0 B)
      }
    net = Instance.parse_ifconfig(ifconfig_string)
    assert_equal ["00:0c:29:f5:d1:9f"], net[:macs]
    assert_equal ["127.0.0.1", "192.168.248.133"], net[:ips].values
  end
    
end