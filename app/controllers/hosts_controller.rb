module MetaVirt
  class HostsController < Sinatra::Base
    configure do
      set :views, File.dirname(__FILE__) + '/../views/hosts/'
      layout do
        File.read(File.dirname(__FILE__) + '/../views/layout.erb' )
      end
    end
    
    get '/' do
      @hosts = Host.all
      erb :index
    end

    get '/new' do
      @host = Host.new
      erb :new
    end
    
    post '/' do
      @host Host.create(params)  #or = Host[:name=>params[:name]]
      @host.update params
      @host.save
      erb :show
    end
    
    get '/:host_name' do
      @host = Host[:name=>params[:host_name]]
      erb :show
    end
    
  end
end