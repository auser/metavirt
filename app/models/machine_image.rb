require 'rubygems'
require 'uuid'
require 'fileutils'
require 'xmlsimple'

$:.unshift(::File.join(::File.dirname(__FILE__), "/vendor/gems/poolparty/lib/"))


module MetaVirt
  class MachineImage #< Sequl::Model
    include Dslify
    
    default_options :cpus   => 1,
                    :memory => 256,
                    :arch   => 'i386',
                    :network => 'defualt'
    
    attr_reader :repository
    attr_accessor :image_id, :root_disk_image
    
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
      set_vars_from_options default_options.merge(options)
    end
    
    def name
      "#{image_id}.tgz"
    end
    
    def to_s
      image_id
    end
    
    def register_image(opts={})
      @uuid=UUID.generate
      options = {:file =>nil}.merge! opts
      @image_id = "mvi_#{@uuid[0..7]}.tgz"
      FileUtils.copy_file(options[:file].path, "#{path}.tgz")
      unbundle
      @root_disk_image = Dir["#{path}/*/*.qcow"].first #FIXME: this is a weak, optimistic method
      File.open("#{path}/domain.xml",'w'){|f| f << erb(:domain_xml)}
    end
    
    def path
      "#{repository}/#{image_id}"
    end
    
    def rsync_to(target, rsync_opts='')
      `rsync #{rsync_opts} #{path}`
    end
    
    def unbundle
      FileUtils.mkdir_p(path)
      `tar -C #{path} -zxvf #{path}.tgz`
    end
    
    def read_domain_xml
      filename = Dir["#{path}/*/*.xml"].first  #FIXME: this is a weak, optimistic method
      hsh = XmlSimple.xml_in(filename, 'KeyToSymbol'=>true)
      # hsh.delete :uuid
      # hsh.deep_delete :mac
      hsh[:devices].first[:disk].last[:source]
    end
    
    def self.available_hypervisors
      ["xen", "kvm", "qemu", "kqemu"]
    end
    
    
  end
end
