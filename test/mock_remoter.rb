require 'uuid'

class MockRemoter
  def self.generate_hash
    uuid = UUID.generate.gsub(/-/, '')
    mac = Array.new(6)
    mac = mac.each_with_index{|v, i| mac[i]=uuid[i*2..i*2+1] }.join(':')
    { :status => 'booting',
      :mac_address => mac,
      :instance_id => "mv_#{uuid[0..8]}",
      :keypair_name => 'id_rsa',
      :remoter_base => 'mock_remoter',
      :authorized_keys => 'ssh-rsa AAAAB3NzaAAABIwA..FU',
      :image_id => 'ami-8b30d5e2',
      :created_at => Time.now
    }
  end
  
  def self.generate_ips
    { :public_ip => "75.#{rand 9}.#{rand 9}.#{rand 9}.#{rand 9}",
      :internal_ip => "10.#{rand 9}.#{rand 9}.#{rand 9}.#{rand 9}"
    }
  end
  
  def launch_new_instance!(o={})
    ip_not_assigned_yet = self.class.generate_hash
    @inst = ip_not_assigned_yet.merge(self.class.generate_ips)
    ip_not_assigned_yet
  end
  
  def terminate_instance(id)
  end
  
  def describe_instance(id)
    @inst ||= self.class.generate_hash
  end
  
  def describe_instances(o={})
    @inst ||= self.class.generate_hash
  end
end