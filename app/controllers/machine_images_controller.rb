module MetaVirt
  class MachineImagesController < Sinatra::Base
    configure do
      set :views, File.dirname(__FILE__) + '/../views/machine_images/'
      layout do
        File.read(File.dirname(__FILE__) + '/../views/layout.erb' )
      end
    end
    
    get '/' do
      erb :index
    end
    
    get '/new' do
      erb :new
    end
    
    get '/:image_id' do      
      @mvi = MachineImage.find params[:image_id]
      if requested?(:html)
        erb :show 
      else
        @mvi.to_json
      end
    end
    
    put '/delete' do
      @mvi = MachineImage.find params[:image_id]
      @mvi.delete
    end
    
    post '/' do
      mi = MachineImage.new(params)
      mi.register_image :root_disk_image=>params[:root_disk_image]
      [mi.name].to_json
    end
    
  end
end
