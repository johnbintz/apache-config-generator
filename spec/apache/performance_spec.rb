require 'spec_helper'

describe Apache::Config, "performance settings" do
  let(:apache) { Apache::Config }
  before { apache.reset! }

  it "should set keepalive" do
    apache.activate_keepalive({ :timeout => 10, :requests => 100 })

    apache.to_a.sort.should == [
      'KeepAlive On',
      'KeepAliveTimeout 10',
      'MaxKeepAliveRequests 100'
    ]
  end
end
