class VmxFile
    attr_reader :name
  def self.defaults
    {
    ".encoding" => "UTF-8",
    "config.version" => "8",
    "virtualHW.version" => "6",
    "guestOS" => "other26xlinux",
    "displayName" => "PoolParty vmx",
    "vumvcpus" => "1",
    "memsize" => "256",
    "MemAllowAutoScaleDown" => "TRUE",
    "MemTrimRate" => "-1",
    "gui.powerOnAtStartup" => "FALSE",
    "gui.fullScreenAtPowerOn" => "FALSE",
    "gui.exitAtPowerOff" => "FALSE",
    "uuid.action" => "create",
    # Settings for VMware Tools
    "tools.remindInstall" => "FALSE",
    "tools.upgrade.policy" => "upgradeAtPowerCycle",
    # Startup hints interfers with automatic startup of a virtual machine
    # This setting has no effect in VMware Player
    "hints.hideAll" => "TRUE",

    # Enable time synchronization between computer
    # and virtual machine
    "tools.syncTime" => "TRUE",

    # USB settings
    # This config activates USB
    "usb.present" => "TRUE",
    "usb.generic.autoconnect" => "FALSE",

    # First serial port, physical COM1 is available
    "serial0.present" => "FALSE",
    "serial0.fileName" => "Auto Detect",
    "serial0.autodetect" => "TRUE",
    "serial0.hardwareFlowControl" => "TRUE",

    # Optional second serial port, physical COM2 is not available
    "serial1.present" => "FALSE",

    # First parallel port, physical LPT1 is available
    "parallel0.present" => "FALSE",
    "parallel0.fileName" => "Auto Detect",
    "parallel0.autodetect" => "TRUE",
    "parallel0.bidirectional" => "TRUE",

    # Sound settings
    "sound.present" => "TRUE",
    "sound.fileName" => "-1",
    "sound.autodetect" => "TRUE",

    # Logging
    # This config activates logging, and keeps last log
    "logging" => "TRUE",
    "log.fileName" => "PoolParty.log",
    "log.append" => "TRUE",
    "log.keepOld" => "3",

    # These settings decides interaction between your
    # computer and the virtual machine
    "isolation.tools.hgfs.disable" => "FALSE",
    "isolation.tools.dnd.disable" => "FALSE",
    "isolation.tools.copy.enable" => "TRUE",
    "isolation.tools.paste.enabled" => "TRUE",

    # Other default settings
    "svga.autodetect" => "TRUE",
    "mks.keyboardFilter" => "allow",
    "snapshot.action" => "autoCommit",

    # First network interface card
    "ethernet0.present" => "TRUE",
    "ethernet0.virtualDev" => "vlance",
    "ethernet0.connectionType" => "nat",
    "ethernet0.addressType" => "generated",
    "ethernet0.generatedAddressOffset" => "0",

    # Settings for physical floppy drive
    "floppy0.present" => "FALSE",

    # First IDE disk, size 4800Mb
    "ide0:0.present" => "TRUE",
    "ide0:0.fileName" => "PoolParty.vmdk",
    "ide0:0.mode" => "persistent",
    "ide0:0.startConnected" => "TRUE",
    "ide0:0.writeThrough" => "TRUE",
    
    "checkpoint.vmState" => "",
    "virtualHW.productCompatibility" => "hosted",
    "ide0:0.redo" => "",
    "vmotion.checkpointFBSize" => "65536000",
    "parallel0.startConnected" => "FALSE",
    "serial0.startConnected" => "FALSE"
    }
  end
  
  def initialize(filepath="vmxfile", o={})
    @name = filepath
    dsl_options.merge!(o)
  end
  
  def set(k,v)
    dsl_options["#{k}"] = v
  end
  
  def dsl_options
    @dsl_options ||= self.class.defaults
  end
  
  def compile
    ::File.open("#{name}.vmx", "w") {|f| f << to_vmx }
  end
  def to_vmx
    out = []
    dsl_options.each_with_index do |arr, idx|
      out << "#{arr[0]}=\"#{arr[1]}\""
      out << "\n" if idx % 5 == 0
    end
    out.join("\n")
  end
end