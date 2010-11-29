require 'rubygems'
require 'bundler'

Bundler.require(:default)

$LOAD_PATH << 'lib'

require 'yaml'
require 'apache/config'

namespace :apache do
  desc "Generate the configs"
  task :generate, :path do |t, args|
    Dir[File.join(args[:path], '**', '*.rb')].each do |file|
      require file
    end
  end
end

task :reek do
  system('reek -c config/config.reek lib/*')
end
