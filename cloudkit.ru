require 'rubygems'
require 'cloudkit'
require 'rack'

require 'rufus/tokyo' # gem install rufus-tokyo
CloudKit.setup_storage_adapter(Rufus::Tokyo::Table.new('cloudkit.tdb'))

use Rack::Session::Pool
# use CloudKit::OAuthFilter
# use CloudKit::OpenIDFilter
use CloudKit::Service, :collections => [:machine_images, :instances, :notes]

run lambda {|env| [200, {'Content-Type' => 'text/html', 'Content-Length' => '5'}, ['HELLO']]}
