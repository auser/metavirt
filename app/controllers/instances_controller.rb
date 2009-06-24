module MetaVirt
  class InstancesController < Sinatra::Base
    configure do
      set :views, File.dirname(__FILE__) + '/../views/instances/'
      layout do
        File.read(File.dirname(__FILE__) + '/../views/layout.erb' )
      end
    end
        # 
        # get "/" do
        #   @instances = DB[:instances]
        #   erb :home
        # end
        
    get '/' do
      @instances = Instance.all
      if requested?(:html)
        erb :index 
      else
        @instances.to_json
      end
    end
    
    get "/:instance_id\/?" do
      @instance = Instance.find(:instance_id=>params[:instance_id])
      response.status=404 if @instance.nil?
      if requested?(:html)
        erb :show 
      else
        @instance.to_json
      end
    end

    # TODO: activate this, and delete from app.rb
    # put "/?" do
    #   params =  JSON.parse(@env['rack.input'].read).symbolize_keys!
    #   p [:params, params]
    #   puts "\n----------\n"
    #   instance = Instance.safe_create(params)
    #   launched = instance.start!
    #   puts "Started instance #{launched.inspect}\n"
    #   instance.to_json
    # end
  
    post "/booted" do
      ifconfig_data = @env['rack.input'].read
      i_to_i = Instance.map_ip_to_interface(ifconfig_data)
      Metavirt::Log.info "Instance i_to_i: #{i_to_i.inspect} ==\n\n#{ifconfig_data}"
      net = Instance.parse_ifconfig(ifconfig_data)
      Metavirt::Log.info "Instance map_ip_to_interface: #{net.inspect}"
      instance = Instance[:status=>['booting', 'pending', 'running'],
                          :mac_address=>[net[:macs]] ] 
      Metavirt::Log.info "Instance is: #{instance.inspect}"
      return @response.status=404 if !instance
      instance.update(:status=>'running',
                      :internal_ip=>(net[:ips]["eth0"] rescue nil),
                      :public_ip=>(net[:ips]["eth0"] rescue nil),
                      :ifconfig => net[:ifconfig_data]
                     )
      Metavirt::Log.info "Instance updated: #{instance.inspect}"
      instance.authorized_keys
    end
    
    delete '/:instance_id' do
      puts params.inspect
      puts CGI.unescape(params[:instance_id])
      instance = Instance[:instance_id=>CGI.unescape(params[:instance_id])].terminate!
      instance.to_json
    end
    
  end
end