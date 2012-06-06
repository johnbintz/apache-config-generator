module Apache
  autoload :Apachify, 'apache/apachify'
  autoload :Config, 'apache/config'
  autoload :Directories, 'apache/directory'
  autoload :Logging, 'apache/logging'
  autoload :Master, 'apache/master'
  autoload :Modules, 'apache/modules'
  autoload :Performance, 'apache/performance'
  autoload :Permissions, 'apache/permissions'
  autoload :Rewrites, 'apache/rewrites'
  autoload :SSL, 'apache/ssl'
  autoload :MPM, 'apache/mpm_prefork'
  autoload :Proxy, 'apache/proxy'

  module Rake
    autoload :Support, 'apache/rake/support'
  end
end

require 'apache/core_ext/hash'
require 'apache/core_ext/string'
require 'apache/core_ext/symbol'
require 'apache/core_ext/fixnum'
require 'apache/core_ext/array'
