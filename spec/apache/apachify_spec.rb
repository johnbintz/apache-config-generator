require 'spec_helper'
require 'apache/apachify'

describe Apache::Apachify, "extends objects to apachify themselves" do
  it "should Apachify the name" do
    [
      %w{test Test},
      %w{test_full_name TestFullName},
      %w{ssl_option SSLOption},
      %w{exec_cgi ExecCGI},
      %w{authz_ldap_authoritative AuthzLDAPAuthoritative},
      %w{authz_ldap_url AuthzLDAPURL},
      [ ["name", "other_name"], [ 'Name', 'OtherName' ] ]
    ].each do |input, output|
      input.apachify.should == output
    end
  end

  it "should optionify the symbol" do
    [
      [ :not_multiviews, '-Multiviews' ]
    ].each do |symbol, output|
      symbol.optionify.should == output
    end
  end
end
