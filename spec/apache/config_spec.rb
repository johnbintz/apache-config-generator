require 'apache/config'
require 'fileutils'

describe Apache::Config, "builds configurations" do
  let(:apache) { Apache::Config }

  before { apache.reset! }

  def set_apache_env(env)
    Object.send(:remove_const, :APACHE_ENV) if Object.const_defined? :APACHE_ENV
    Object.send(:const_set, :APACHE_ENV, env)
  end

  describe '.environment_ok?' do
    subject { Apache::Config.environment_ok?(:good) }

    context 'empty environment' do
      before { set_apache_env(true) }

      it { should be_true }
    end

    context 'bad environment' do
      before { set_apache_env(:bad) }

      it { should be_false }
    end

    context 'good environment' do
      before { set_apache_env(:good) }

      it { should be_true }
    end
  end

  describe '.disable!' do
    context 'is enabled by default' do
      it { apache.instance_variable_get(:@is_disabled).should be_false }
      it { apache.disabled?.should be_false }

      context 'writes config' do
        before {
          FileUtils.expects(:mkdir_p).once
          File.expects(:open).once
          apache.build("here") { cats }
        }

        it { apache.written?.should == true }
      end
    end

    context 'disable' do
      before { apache.disable! }

      it { apache.instance_variable_get(:@is_disabled).should be_true }
      it { apache.disabled?.should be_true }

      context 'does not write config' do
        before {
          FileUtils.expects(:mkdir_p).never
          File.expects(:open).never
          apache.build("here") { disable!; cats }
        }

        it { apache.written?.should == false }
      end
    end
  end

  it "should handle indent" do
    apache.line_indent = 1

    [
      [ 'hello', '  hello' ],
      [ [ 'hello', 'goodbye' ], [ '  hello', '  goodbye' ] ]
    ].each do |input, output|
      apache.indent(input).should == output
    end
  end

  it "should add a line to the config" do
    apache << "hello"
    apache.to_a.should == [ 'hello' ]

    apache + [ 'goodbye' ]
    apache.to_a.should == [ 'hello', 'goodbye' ]
  end

  it "should handle method_missing" do
    apache.test "test2", "test3"
    apache.test_again! "test2", "test3"

    apache.to_a.should == [
      'Test "test2" "test3"',
      'TestAgain test2 test3'
    ]
  end

  it "should quoteize properly" do
    ["test", "test2"].quoteize.should == %w{"test" "test2"}
    [:test, :test2].quoteize.should == %w{test test2}
  end

  it "should blockify a block" do
    apache.blockify("Tag", [ 'part', 'part2' ]) do
      something "goes here"
    end.should == ['', '<Tag "part" "part2">', '  Something "goes here"', '</Tag>', '']
  end

  it "should blockify the name of a block" do
    [
      [ 'part', '"part"' ],
      [ :part, 'part' ],
      [ [ 'part', 'part2' ], '"part" "part2"' ]
    ].each do |name, attribute|
      name.blockify.should == attribute
    end
  end

  it "should handle a build" do
    apache.written?.should be_false

    FileUtils.mkdir_p 'test'
    apache.build('test/fake.conf') { my_test "this" }.should == [ 'MyTest "this"' ]
    FileUtils.rm 'test/fake.conf'

    apache.written?.should be_true
  end

  it "should handle building if the environment is correct" do
    set_apache_env(:test)

    apache.build_and_return_if(:other) { my_test 'this' }.should == nil
    apache.build_and_return_if(:test) { my_test 'this' }.should == [ 'MyTest "this"' ]
  end

  it "should only execute a block if the environment is correct" do
    set_apache_env(:test)

    test = 0
    apache.if_environment(:other) { test = 1 }
    test.should == 0

    test = 0
    apache.if_environment(:test) { test = 1 }
    test.should == 1
  end

  it "should create an IfModule block" do
    apache.if_module("test") { my_test }
    apache.to_a.should == [ '', '<IfModule test_module>', '  MyTest', '</IfModule>', '' ]
  end

  it "should create a Directory block" do
    dir = File.dirname(__FILE__)

    apache.directory(dir) { my_test }
    apache.to_a.should == [ '', %{<Directory "#{dir}">}, '  MyTest', '</Directory>', '' ]

    apache.reset!

    apache.directory('/does/not/exist') { my_test }
    apache.to_a.should == [ '', %{<Directory "/does/not/exist">}, '  MyTest', '</Directory>', '' ]
  end

  it "should create a LocationMatch block" do
    apache.location_match(%r{^/$}) { my_test }
    apache.to_a.should == [ '', '<LocationMatch "^/$">', '  MyTest', '</LocationMatch>', '' ]
  end
end

describe "Apache::Config used separately" do
  context "it works" do
    subject { Apache::Config.build_and_return { this_works }.first }

    it { should == "ThisWorks" }
  end
end
