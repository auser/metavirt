require File.dirname(__FILE__) + "/../../../../../test_helper"
require "shoulda"

class VmxFileTest < Test::Unit::TestCase
  context "vmx_file" do
    should "give a new vmx file" do
      assert VmxFile.new.class, VmxFile
      vx = VmxFile.new("incredulous")
      vx.set "parallel1", "parallel1.scope"
      assert_equal "parallel1.scope", vx.dsl_options["parallel1"]
      assert_match /parallel1=\"parallel1.scope\"/, vx.to_vmx
      vx.compile
      assert File.file?("incredulous.vmx")
      FileUtils.rm "incredulous.vmx"
    end
  end
  
end