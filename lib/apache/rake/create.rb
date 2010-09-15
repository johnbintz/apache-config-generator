require 'fileutils'
require 'yaml'
require 'apache/config'
require 'apache/rake/create'
require 'rainbow'

CONFIG = Hash[YAML.load_file('config.yml').collect { |k,v| [ k.to_sym, v ] }]

def get_environments
  CONFIG[:source_path] = File.expand_path(CONFIG[:source])

  Dir[File.join(CONFIG[:source_path], '**', '*.rb')].collect { |file|
    File.readlines(file).find_all { |line| line[%r{(if_environment|build_if)}] }.collect { |line| line.scan(%r{:[a-z_]+}) }
  }.flatten.uniq.sort.collect { |name| name[1..-1] }
end

namespace :apache do
  desc "Create all defined configs for the specified environment"
  task :create, :environment do |t, args|
    if !args[:environment]
      puts "You need to specify an environment. Available environments:"
      puts
      puts get_environments.collect { |env| "rake apache:create[#{env}]" } * "\n"
      exit 1
    end

    APACHE_ENV = (args[:environment] || 'production').to_sym

    CONFIG[:source_path] = File.expand_path(CONFIG[:source])
    CONFIG[:dest_path] = File.expand_path(CONFIG[:destination])

    Apache::Config.rotate_logs_path = CONFIG[:rotate_logs_path]

    FileUtils.mkdir_p CONFIG[:dest_path]
    Dir.chdir CONFIG[:dest_path]

    Dir[File.join(CONFIG[:source_path], '**', '*.rb')].each do |file|
      puts file.foreground(:green)
      require file
    end
  end

  desc "List all possible environments"
  task :environments do
    puts get_environments * "\n"
  end
end
