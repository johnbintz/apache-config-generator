#!/usr/bin/ruby

require 'rubygems'
gem 'apache-config'
require 'apache/config'

puts Apache::Config.build_and_return do
  this_works
end
