require 'uuid'
# require File.dirname(__FILE__)+"/../lib/compute_providers/remoter_base"
# require File.dirname(__FILE__)+"/../lib/compute_providers/remote_instance"

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
    MockRemoterInstance.new(ip_not_assigned_yet)
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

require 'ostruct'
class MockRemoterInstance < Hash
  
  def method_missing(*m)
    super and return if m && m.size==1
    if has_key? m.first
      fetch(m.first) 
    elsif has_key? m.first.to_s
      fetch(m)
    else
      super
    end
  end

end