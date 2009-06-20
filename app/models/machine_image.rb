require 'rubygems'
require 'uuid'
require 'fileutils'
require 'xmlsimple'

$:.unshift(::File.join(::File.dirname(__FILE__), "/vendor/gems/poolparty/lib/"))


module MetaVirt
  class MachineImage #< Sequl::Model
    include Dslify
    
    default_options :cpus       => 1,
                    :memory     => 319488,
                    :arch       => 'i386',
                    :network    => 'defualt',
                    :repository => File.expand_path(File.dirname(__FILE__)+'/../../machine_images'),
                    :root_disk_image => nil
                    
    def self.list(alternate_repository=nil)
      repo = alternate_repository || dsl_options[:repository]
      Dir["#{repo}/mvi_*"].collect {|f| f.split('/').last }
    end
    
    def self.find(image_id, opts={})
      target = "#{opts[:repository] || dsl_options[:repository]}/#{image_id}"
      p [:target, target]
      if File.exists?(target)
        new :image_id => image_id
      else
        nil
      end
    end
    
    def initialize(options={})
      set_vars_from_options options
      if File.file?("#{repository}/#{image_id}/#{image_id}.xml") 
        # set variables from domain.xml
        hsh = parse_domain_xml
        root_disk_image hsh[:devices].first[:disk].last[:source].first.file
        uuid hsh[:uuid]
        arch hsh.os.first[:type].first[:arch]
        image_id hsh[:name]
      end
    end
    
    def description(note=nil)
      if note
        FileUtils.mkdir_p(path) if !File.exists?(path)
        File.open("#{path}/description.txt", 'w'){|f| f<< note}
      elsif File.file?("#{path}/description.txt") 
        content = File.read("#{path}/description.txt")
      end
    end
    
    def uuid(n=nil)
      if n.nil?
        @uuid ||= UUID.generate
      else
        @uuid = n
      end
    end
    
    def image_id(n=nil)
      if n.nil?
        @image_id ||= "mvi_#{uuid[0..7]}"
      else
        @image_id = n
      end
    end
    
    def name(n=nil)
      image_id(n)
    end
    
    def to_s
      image_id
    end
    
    #options must contain :root_disk_image and :arch
    def register_image(options={})
      FileUtils.mkdir_p(path)
      FileUtils.cp(
        options[:root_disk_image].tempfile.path, 
        "#{path}/#{options[:root_disk_image].filename}"
      )
      self.root_disk_image File.expand_path("#{path}/#{options[:root_disk_image].filename}")
      write_domain_xml
    end
    
    def path
      "#{repository}/#{image_id}"
    end
    
    def rsync_clone_to(opts={})
      options = {:target     => '/var/metavirt/instances/', 
                 :rsync_opts => '-a'
                }.merge(opts)
      droid = self.class.new(self.dsl_options.merge(options))
      droid.uuid UUID.generate
      FileUtils.mkdir_p("#{path}/clones/#{droid.image_id}")
      droid.root_disk_image("#{options[:target]}/#{root_disk_image_name}")
      droid.write_domain_xml("#{path}/clones/#{droid.image_id}")
      FileUtils.ln_s(root_disk_image, "#{path}/clones/#{droid.image_id}/#{root_disk_image_name}")
      `rsync -L #{options[:rsync_opts]} "#{path}/clones/#{droid.image_id}/" #{options[:target]}`
      # `rsync #{rsync_opts} #{root_disk_image} #{target}`
      droid
    end
    
    def root_disk_image_name
      File.basename(root_disk_image)
    end
    
    def write_domain_xml(location=path)
      template = open(File.dirname(__FILE__)+'/../views/machine_images/domain_xml.erb').read
      @mvi=self  #put in instance varibale for erb
      xml = ERB.new(template).result(binding)
      File.open("#{location}/#{image_id}.xml",'w'){|f| f << xml}
      xml
    end
    
    def domain_xml
      open("#{path}/#{image_id}.xml").read
    end
    
    def parse_domain_xml(location=nil)
      filename = location || File.join(path, "#{image_id}.xml")
      hsh = XmlSimple.xml_in(filename, 'KeyToSymbol'=>true)
      hsh.symbolize_keys!
    end
    
    def to_hash
      dsl_options.merge(
        :domain_xml => domain_xml,
        :image_id => image_id,
        :uuid => uuid
      )
    end
    
    def to_json
      to_hash.to_json
    end
    
  end
end
