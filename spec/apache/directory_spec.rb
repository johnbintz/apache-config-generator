require 'apache/config'

describe Apache::Master, "should provide basic helpers for configuration" do
  let(:apache) { Apache::Config }

  before { apache.reset! }

  it "should create the list of options" do
    { :options => 'Options', :index_options => 'IndexOptions' }.each do |method, tag|
      apache.reset!
      apache.send(method, :test, 'test2')
      apache.to_a.should == [ "#{tag} Test Test2" ]
    end
  end
end
