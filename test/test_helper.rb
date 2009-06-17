ENV["RACK_ENV"] = "test"
require 'rubygems'
require "test/unit"
require 'mocha'
require 'sequel'
require 'ruby-debug'
require 'fileutils'
require  File.dirname(__FILE__)+'/mock_remoter'

$TESTING = true

# setup_test_db
require File.dirname(__FILE__)+"/../db/migrations/01_initialize_db.rb"
DB = Sequel.sqlite unless defined?(DB)
InitializeDB.apply(DB, :up) unless DB.tables.include?(:version)

require File.dirname(__FILE__) + "/../app.rb"

Test::Unit::TestCase.send(:include, Metavirt)

def fake_instance(opts={})
  @inst = Instance.create(MockRemoter.generate_hash.merge(:created_at=>Time.now))
end
