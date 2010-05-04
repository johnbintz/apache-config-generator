require 'apache/config'

describe Apache::Config, "should handle the basics of Apache config" do
  before do
    Apache::Config.reset!
  end

  it "should handle indent" do
    Apache::Config.line_indent = 1

    Apache::Config.indent("hello").should == "  hello"
  end

  it "should add a line to the config" do
    Apache::Config << "hello"
    Apache::Config.config.should == [ 'hello' ]
  end

  it "should handle method_missing" do
    Apache::Config.test "test2", "test3"
    Apache::Config.test_again! "test2", "test3"

    Apache::Config.config.should == [
      'Test "test2" "test3"',
      'TestAgain test2 test3'
    ]
  end

  it "should Apachify the name" do
    Apache::Config.apachify("test").should == "Test"
    Apache::Config.apachify("test_full_name").should == "TestFullName"
  end

  it "should quoteize properly" do
    Apache::Config.quoteize("test", "test2").should == %w{"test" "test2"}
    Apache::Config.quoteize(:test, :test2).should == %w{test test2}
  end

  it "should blockify a block" do
    Apache::Config.blockify("Tag", [ 'part', 'part2' ]) do
      something "goes here"
    end.should == ['<Tag "part" "part2">', '  Something "goes here"', '</Tag>']

    Apache::Config.reset!

    Apache::Config.blockify("Tag", 'part') do
      something "goes here"
    end.should == ['<Tag "part">', '  Something "goes here"', '</Tag>']
  end
end
