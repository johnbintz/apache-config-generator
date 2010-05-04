require 'apache/modules'

describe Apache::Modules, "should build a list of modules" do
  before do
    Apache::Modules.reset!
  end

  it "should handle method_missing" do
    Apache::Modules.mine

    Apache::Modules.modules.should == [ 'LoadModule "mine_module" "modules/mod_mine.so"' ]
  end

  it "should build a set of modules" do
    Apache::Modules.build(:this, :that) do
      mine "my_path"
    end.should == [
      'LoadModule "this_module" "modules/mod_this.so"',
      'LoadModule "that_module" "modules/mod_that.so"',
      'LoadModule "mine_module" "my_path"'
    ]
  end
end
