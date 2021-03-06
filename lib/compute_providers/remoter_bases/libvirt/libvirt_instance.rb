require 'xmlsimple'

module PoolParty
  module Remote
    
    class LibvirtInstance < RemoteInstance
      include Dslify
      
      dsl_methods :name,
                  :image_id,
                  :ip,          # Ip of the remote instance, by default, the public_ip
                  :internal_ip, # Internal ip of the remote instance
                  :public_ip,
                  :status,      # Status of the remote instance
                  :mac_address,
                  :keypair_name,
                  :cloud
      
      # def initialize(o={})
      #   description
      #   super
      # end
      
      def mac_addresses(hsh=nil)
        data = hsh || description
        data[:devices].select{|el| 
          el.has_key? :interface 
          }.collect{|eth|
            eth.interface.collect{|n| n.mac}
          }.flatten.collect{|c| c.values}.flatten
      end
      
      def description
        p command = "virsh dumpxml #{instance_id || name}"
        xml = `#{command}`
        hsh = XmlSimple.xml_in(xml).symbolize_keys!
        hsh[:state] = `virsh domstate #{instance_id || name}`
        hsh[:mac_address] = mac_addresses( hsh ).first
        dsl_options.merge! hsh
        self
      end
      
      # def shutdown
      #   `virsh shutdown #{instance_id}`
      # end
      
    end
    
  end
end