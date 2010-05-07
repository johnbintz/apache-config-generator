require 'spec_helper'

describe Apache::Config, "rewrites" do
  let(:apache) { Apache::Config }
  before { apache.reset! }

  it "should enable the rewrite engine" do
    apache.enable_rewrite_engine :log_level => 1
    apache.to_a.should == [
      '',
      'RewriteEngine on',
      'RewriteLogLevel 1',
      ''
    ]
  end

  it "should add a simple redirect permanent" do
    apache.r301 '/here', '/there'
    apache.to_a.should == [
      'Redirect permanent "/here" "/there"'
    ]
  end

  it "should build rewrites" do
    apache.rewrites do
      rule %r{^/$}, '/test'
    end
    apache.to_a.should == [
      'RewriteRule "^/$" "/test"', ''
    ]
  end
end

describe Apache::RewriteManager, "specific rewrite rules" do
  let(:rewrite) { Apache::RewriteManager }
  before { rewrite.reset! }

  it "should create a rewrite" do
    rewrite.build do
      cond '%{REQUEST_FILENAME}', 'test'
      rule %r{^/$}, '/test'

      r301 %r{^/success$}, '/test'

      rewrite_test '/', '/test'
      rewrite_test '/fail', '/test'
      rewrite_test '/%{REQUEST_FILENAME}', '/test', :request_filename => 'success'
    end.should == [
      'RewriteCond "%{REQUEST_FILENAME}" "test"',
      'RewriteRule "^/$" "/test"',
      'RedirectMatch permanent "^/success$" "/test"'
    ]
  end
end

describe Apache::MatchableThing, "something that can be matched" do
  subject do
    thing = Apache::MatchableThing.new
    thing.rule('here', 'there')

    class << thing
      def tag; "RSpec"; end
    end

    thing
  end

  its(:to_s) { should == 'RSpec "here" "there"' }
  its(:to_a) { should == [ 'RSpec "here" "there"' ] }
end

describe Apache::RewriteRule, "a RewriteRule" do
  subject do
    rule = Apache::RewriteRule.new
    rule.cond('%{REQUEST_FILENAME}', '^/test$')
    rule.rule(%r{^/$}, '/test', :last => true, :preserve_query_string => true)
    rule
  end

  its(:to_s) { should == 'RewriteRule "^/$" "/test" [L,QSA]' }
  its(:to_a) { should == [
    'RewriteCond "%{REQUEST_FILENAME}" "^/test$"',
    'RewriteRule "^/$" "/test" [L,QSA]'
  ] }

  it "should pass the test" do
    subject.test('/').should == '/test'
  end
end

describe Apache::RewriteCondition, "a RewriteCond" do
  subject do
    cond = Apache::RewriteCondition.new
    cond.cond('%{REQUEST_FILENAME}', '^/test$', :or, :case_insensitive, :no_vary)
    cond
  end

  its(:to_s) { should == 'RewriteCond "%{REQUEST_FILENAME}" "^/test$" [OR,NC,NV]' }
end
