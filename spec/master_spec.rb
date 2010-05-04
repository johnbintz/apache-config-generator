require 'apache/config'

describe Apache::Master, "should provide basic helpers for configuration" do
  before do
    Apache::Config.reset!
  end

  it "should build the modules with the provided block" do
    Apache::Config.modules(:this, :that) do
      my "is here"
    end

    Apache::Config.config.should == [
      'LoadModule "this_module" "modules/mod_this.so"',
      'LoadModule "that_module" "modules/mod_that.so"',
      'LoadModule "my_module" "is here"',
    ]
  end
end
