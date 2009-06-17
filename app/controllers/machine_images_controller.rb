module MetaVirt
  class MachineImagesController < Sinatra::Base
    configure do
      set :views, File.dirname(__FILE__) + '/../views/machine_images/'
    end
    
    get '/' do
      erb :index
    end
    
    get '/new' do
      erb :new
    end
    
    post '/' do
      mi = MachineImage.new
      mi.register_image :file=>params[:image_file][:tempfile]
      [mi.name].to_json
    end
    
  end
end
