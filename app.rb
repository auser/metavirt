require "rubygems"
require 'ruby-debug'
require 'pp'
$:.unshift File.dirname(__FILE__) + "/lib"
Dir["#{File.dirname(__FILE__)}/vendor/gems/*/lib/"].each do |lib|
  $:.unshift lib
end
$:.unshift File.dirname(__FILE__)
gems = %w(sinatra sequel json dnssd columbus).each {|gem| require gem}

Dir[File.dirname(__FILE__)+"/lib/*.rb"].each{|lib| require lib}
Dir[File.dirname(__FILE__)+"/lib/*/*.rb"].each{|lib| require lib}

DB = Sequel.connect("sqlite://db/metavirt.db") unless defined?(DB)

Dir[File.dirname(__FILE__)+"/app/*/*.rb"].each{|part| require part}

module MetaVirt
  include Rack::Utils
  alias_method :h, :escape_html
  
  class MetadataServer < Sinatra::Base
    SERVER_URI='http://192.168.4.4.10:3000' unless defined? SERVER_URI
    
    #TODO: add support for accepting clouds.rb from POST data
    # require "/Users/mfairchild/Code/poolparty_fresh/examples/metavirt_cloud.rb"
    # clouds.keys.each{|name| MetaVirt::Cloud.find_or_create(:name=>name.to_s) }
    
    configure do
      set :views, File.dirname(__FILE__) + '/app/views'
      Metavirt::Log.init "metavirt", "#{Dir.pwd}/log"
      
      if ENV['COLUMBUS'] && !$TESTING 
        Columbus::Server.name = "columbus-server"
        Columbus::Server.description = ENV["IP"] ? ENV["IP"] : Instance.parse_ifconfig(%x{ifconfig})[:ips].values.last
        
        @pid = fork do
           Signal.trap(:USR1) {puts "STOPPING on USR1"; exit()}
           Signal.trap(:TERM) {puts "STOPPING on TERM"; exit()}
           Signal.trap(:INT) {puts "STOPPING on INT"; exit()}
           while true do
             Columbus::Server.announce("vmnet8")
             sleep(90)
           end           
         end
         Process.detach(@pid)
      end
    end
    
    get "/" do
      @instances = DB[:instances]
      erb :home
    end
    
    get '/boot_script' do
      # @host = "#{@env['rack.url_scheme']}//#{@env['HTTP_HOST']}".strip
      @response['Content-Type']='text/plain'
      erb 'boot_script'.to_sym, :layout=>:none
    end
    
    get '/bootstrap' do
      # @host = "#{@env['rack.url_scheme']}//#{@env['HTTP_HOST']}".strip
      @response['Content-Type']='text/plain'
      erb :bootstrap, :layout=>:none
    end
    
    get '/pools/' do
      erb "#{pools.keys.inspect}"
    end

    get '/clouds/' do
      @clds = clouds
      erb :clouds
    end
  
    get '/cloud/:name' do
      @cld = clouds[params[:name].to_sym]
      @cld.to_properties_hash.to_json
    end
    
    put( /\/run-instance|\/launch_new_instance/ ) do
      params =  JSON.parse(@env['rack.input'].read).symbolize_keys!
      instance = Instance.safe_create(params)
      launched = instance.start!
      puts "Started instance #{launched.inspect}\n"
      instance.to_json
    end
    
    #curl http://169.254.169.254/1.0/meta-data/public-keys/0/openssl
    get "/:version/meta-data/public-keys/0/openssl" do
      instance = Instance.find(:internal_ip=>@request.ip)
      instance ? instance.authorized_keys.to_s : @response.status=404
    end

    put '/meta-data/public-keys/0/openssl' do
    end

  end
end

include MetaVirt #just to make my irb sessions easier