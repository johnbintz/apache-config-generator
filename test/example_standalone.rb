#!/usr/bin/ruby

require 'rubygems'
gem 'apache-config-generator'
require 'apache/config'

puts Apache::Config.build_and_return { this_works }
