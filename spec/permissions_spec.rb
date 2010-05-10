require 'spec_helper'

describe Apache::Config, "permissions" do
  let(:apache) { Apache::Config }
  before { apache.reset! }

  it "should set up allow and deny groups" do
    apache.deny_from_all!
    apache.to_a.should == [ 'Order deny,allow', 'Deny from all' ]

    apache.reset!
    apache.allow_from_all!
    apache.to_a.should == [ 'Order allow,deny', 'Allow from all' ]
  end

  it "should allow from somewhere" do
    apache.allow_from '1.2.3.4'
    apache.to_a.should == [ 'Allow from "1.2.3.4"' ]
  end

  # Verify the blob output in apache itself, just make sure the method doesn't bomb
  it "should verify some blob functions don't fail" do
    apache.default_restrictive!
    apache.no_htfiles!

    apache.basic_authentication("My site", '/path/to/users/file', :user => :john)
    apache.ldap_authentication("My site", 'ldap url', 'ldap-path' => 'path')
  end

  it "should add an auth require" do
    apache.apache_require 'user', :john, :scott
    apache.to_a.should == [ 'Require user john scott' ]
  end
end
