require 'rubygems'
require 'bundler'

Bundler.require(:default)

$LOAD_PATH << 'lib'

require 'yaml'

require 'apache'
require 'rspec/core/rake_task'

namespace :apache do
  desc "Generate the configs"
  task :generate, :path do |t, args|
    Dir[File.join(args[:path], '**', '*.rb')].each do |file|
      require file
    end
  end
end

namespace :spec do
  desc "Run RCov tests"
  RSpec::Core::RakeTask.new(:rcov) do |t|
    t.pattern = 'spec/*.rb'
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec', '--exclude', 'gems']
    t.rspec_opts = ['-b']
  end
end

task :reek do
  system('reek -c config/config.reek lib/*')
end
