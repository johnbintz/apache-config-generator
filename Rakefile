require 'yaml'
require 'apache'

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

task :gem do
  system %{rm *.gem}
  system %{gem build apache-config-generator.gemspec}
  system %{gem install apache-config-generator-*.gem}
end

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

