require 'rubygems'
require 'uuid'
require "macmap"

module MetaVirt
  class Instance < Sequel::Model
    include Dslify
    
    default_options :instances_playground => '/var/metavirt/instances'
    
    #save to cloudkit if available
    def save(*args, &block)
      super
      # begin
      #     require 'restclient'
      #     server["/instances/#{instance_id}"].put(to_json)
      #   rescue Exception => e
      #     Metavirt::Log.error "cloudkit fail:\n\t#{e.inspect}"
      #   end
      self
    end
    
    # server is used if you want to also store instance information in cloudkit
    # def server(server_config={})
    #     if @server
    #       @server
    #     else
    #       opts = { :content_type  =>'application/json', 
    #                :accept        => 'application/json',
    #                :host          => 'http://localhost',
    #                :port          => '3002'
    #               }.merge(server_config)
    #       @uri = "#{opts.delete(:host)}:#{opts.delete(:port)}"
    #       @server = RestClient::Resource.new( @uri, opts)
    #     end
    #   end
    
    def self.defaults
      { :launch_time => nil,
        :authorized_keys => nil,
        :keypair_name => nil,
        :image_id => nil,
        :remoter_base => :vmrun,
        :created_at => Time.now,
        :remoter_base_options => nil,
        :instance_id => generate_instance_id,
        :vmx_file => nil,
        :status => 'booting',
        :instance_storage_path => '/var/metavirt/instances/'
       }
    end
    # 
    # def instance_storage_path
    #   self.class.defaults.instance_storage_path
    # end
    
    # def self.new(params={})
    #   safe_params = Instance.defaults.merge(default_params(params))
    #   # safe_params[:authorized_keys] << params[:public_key].to_s
    #   safe_params[:remoter_base_options] = params[:remote_base].to_yaml if params[:remote_base]
    #   inst = super(safe_params)
    # end
    
    def self.safe_create(params={})
      safe_params = Instance.defaults.merge(default_params(params))
      # safe_params[:authorized_keys] << params[:public_key].to_s
      safe_params[:remoter_base_options] = params[:remote_base].to_yaml if params[:remote_base]
      inst = create safe_params
      inst.prepare_image if inst.remoter_base.match /vmrun|libvirt/
      inst
    end
    
    def prepare_image
      mvi = MachineImage.find(image_id)
      raise("Can't find image #{image_id}") if mvi.nil?
      droid = mvi.rsync_clone_to :target   => "#{instances_playground}/#{instance_id}",
                                 :image_id => instance_id
      if provider.respond_to? :register_image
        provider.register_image("#{instances_playground}/#{instance_id}/#{droid.image_id}.xml")
      end
      droid
    end
    
    def start!
      opts = self.to_hash
      # remove remoter_base_options yaml string and yaml load into options
      opts.delete(:remoter_base_options)
      opts.merge! options if options
      launched = provider.launch_new_instance!(opts)
      p [:opts, opts]
      launched[:launch_time] = Time.now
      launched.symbolize_keys! if launched.respond_to? :symbolize_keys!
      if remoter_base=='vmrun'
        launched.delete(:instance_id)  # we want to use the metavirt id
        launched.delete(:status)  #vmrun always returns 'running' so we override it here untill node checks in
      end
      set Instance.safe_params(launched)
      launched_at = Time.now
      status      = 'booting'
      save
    end
    
    def terminate!
      if remoter_base == 'vmrun'
        provider.terminate_instance!(:vmx_file=>vmx_file)
      else
        provider.terminate_instance!(:instance_id=>instance_id)
      end
      update(:status=>'terminated', :terminated_at=>Time.now)
    end

    def to_hash
      hsh = columns.inject({}){|h, k| h[k]=values[k];h}
      hsh[:ip]=public_ip
      hsh.delete(:id)
      hsh.reject {|k,v| v.nil? || (v.empty? if v.respond_to? :empty)}
    end
    
    def to_json
      to_hash.to_json
      # Yajl::Encoder.new.encode(to_hash)
    end
    
    # Dump to html
    def to_xoxo
      require 'facets/xoxo'
      XOXO.dump self.to_hash
    end
    
    # The remoter_base as a ruby object
    def provider
      @provider ||= find_constant( remoter_base, ::PoolParty::Remote )
    end
    
    def options
      remoter_base_options.nil? ? nil : YAML.load(remoter_base_options)
    end
    
    def self.parse_ifconfig(str)
      # ips = str.match(/inet (addr:)?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/i).captures
      macs = str.match(/Ether.*((?:[0-9a-f]{2}[:-]){5}[0-9a-f]{2})/i).captures
      {:ips=>map_ip_to_interface(str), :macs=>macs}
    end
    def parse_ifconfig
      self.parse_ifconfig(ifconfig)
    end
    
    def self.parse_ips_from_str(str)
      out = []
      str.split("\n").collect do |line|          
        ip = line.match(/inet (addr:)?(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/i)
        if ip
          ip = ip.captures.compact.to_s.gsub(/addr:/, '')
          out << ip
        end
      end
      out
    end
    
    def self.map_ip_to_interface(str=ifconfig)
      Macmap.map_iface_to_ip str
    end
    
    def self.to_json(filters=nil)
      if filters
        rows = dataset.filter(filters)
      else
        rows = dataset.all
      end
      rows.collect{|row| row.values}.to_json
    end
    
    private
    def self.default_params(params={})
      Instance.defaults.inject({}){|sum, (k,_v)| sum[k]=params[k] if params[k];sum}
    end
    def self.safe_params(params={})
      cols = Instance.columns.inject({}){|sum, (k,_v)| sum[k]=params[k] if params[k];sum}
      cols.delete(:id)
      cols
    end
    
    def self.generate_instance_id
      uuid = UUID.generate.gsub(/-/, '')
      "i_#{uuid[0..8]}"
    end
    def generate_instance_id
      self.class.generate_instance_id
    end
    
    def self.generate_mac_address
      uuid = UUID.generate.gsub(/-/, '')
      mac = Array.new(6)
      mac_address = mac.each_with_index{|v, i| mac[i]=uuid[i*2..i*2+1] }.join(':')
    end
    
    # Take a string and return a ruby object if  found in the namespace.
    def find_constant(name, base_object=self)
      begin
        const = base_object.constants.detect{|cnst| cnst == camelcase(name)}
        base_object.module_eval const
      rescue Exception => e
        puts "#{name.camelcase} is not defined. #{e}"
        nil
      end
    end
    
    def camelcase(str)
      str.gsub(/(^|_|-)(.)/) { $2.upcase }
    end
        
    
  end
end

