require 'spec_helper'

describe Apache::Config, "prefork MPM" do
  let(:apache) { Apache::Config }
  before { apache.reset! }

  it "should build the prefork options" do
    apache.prefork_config do
      start 10
      spares 10, 30
      limit 20
      clients 100
      max_requests 1000
    end

    apache.to_a.should == [
      '',
      '# Prefork config',
      '',
      'StartServers 10',
      'MinSpareServers 10',
      'MaxSpareServers 30',
      'ServerLimit 20',
      'MaxClients 100',
      'MaxRequestsPerChild 1000'
    ]
  end
end
