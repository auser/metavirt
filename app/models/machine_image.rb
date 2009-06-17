require 'rubygems'
require 'uuid'
require 'fileutils'
$:.unshift(::File.join(::File.dirname(__FILE__), "/vendor/gems/poolparty/lib/"))


module MetaVirt
  class MachineImage #< Sequl::Model
    
    attr_reader :repository
    attr_accessor :image_id
    
    @repository =  File.dirname(__FILE__)+'/../../machine_images/'
    
    class << self
      attr_reader :repository
    end
    
    def self.list
      Dir["#{repository}/mvi_*"].collect {|f| f.split('/').last }
    end
    
    def self.find(image_id)
      if File.exists?("#{repository}/#{image_id}") 
        new :image_id => image_id
      else
        nil
      end
    end
    
    def initialize(options={})
      @repository = options[:repository] || self.class.repository
      @image_id = options[:image_id]
    end
    
    def name
      @image_id
    end
    
    def register_image(opts={})
      options = {:file =>nil}.merge! opts
      @name = "mvi_#{UUID.generate[0..7]}"
      FileUtils.copy_file(options[:file].path, path)
    end
    
    def path
      "#{repository}/#{@image_id}"
    end
    
    def rsync_to(target, rsync_opts='')
      `rsync #{rsync_opts} #{path}`
    end
    
  end
end
