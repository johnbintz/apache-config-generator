require 'spec_helper'

describe Apache::Config, "logging directives" do
  let(:apache) { Apache::Config }
  before { apache.reset! }

  it "should handle a defined log type" do
    apache.rotate_logs_path = '/path/to/rotatelogs'

    [ :custom, :error, :script, :rewrite ].each do |type|
      apache.reset!
      apache.send("#{type}_log".to_sym, 'test', 'test2')
      apache.to_a.should == [ %{#{type.to_s.capitalize}Log "test" test2} ]

      apache.reset!
      apache.send("rotate_#{type}_log".to_sym, 'test', 86400, 'test2')
      apache.to_a.should == [ %{#{type.to_s.capitalize}Log "|/path/to/rotatelogs test 86400" test2} ]
    end
  end

  it "should give log formats" do
    apache.combined_log_format
    apache.common_log_format
  end
end
