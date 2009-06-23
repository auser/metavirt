require "rubygems"
require 'rack'
# require 'rack/contrib'
require File.dirname(__FILE__)+"/app.rb"
disable :run

# use Rack::BounceFavicon
use Rack::Session::Cookie
use Rack::Static, :urls => %w(/stylesheets /javascripts /images),
                  :root => File.dirname(__FILE__) + "/public"
use Rack::Reloader #or tmp/always_restart.txt to reload on each request with passenger
use Rack::ShowExceptions
# use Rack::PostBodyContentTypeParser
use Rack::CommonLogger
 # use Rack::Lint #doesn't work with rack

map "/" do
  run MetaVirt::MetadataServer
end

map "/instances" do
  run MetaVirt::InstancesController
end 
map "/machine_images" do
   run MetaVirt::MachineImagesController
end


# Rack::Handler::Ebb
