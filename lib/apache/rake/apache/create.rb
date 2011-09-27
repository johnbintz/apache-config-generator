require 'apache'

include Apache::Rake::Support

task :default => 'apache:create'

def capture_stdout
  buffer = StringIO.new
  $stdout = buffer
  yield
  $stdout = STDOUT
  buffer.rewind
  buffer.read
end

namespace :apache do
  desc "Create all defined configs for the specified environment"
  task :create, :environment do |t, args|
    if get_environments.empty?
      APACHE_ENV = true
    else
      need_environment if !args[:environment] && !get_default_environment

      APACHE_ENV = (args[:environment] || get_default_environment).to_sym
    end

    Apache::Config.rotate_logs_path = config[:rotate_logs_path]

    FileUtils.rm_rf config[:destination_path]
    FileUtils.mkdir_p config[:destination_path]
    Dir.chdir config[:destination_path]

    CONFIG = config

    ENVIRONMENT_CONFIG = (config[:environments][APACHE_ENV] rescue nil)

    Dir[File.join(config[:source_path], '**', '*.rb')].each do |file|
      Apache::Config.reset!
      output = capture_stdout { require file }

      if Apache::Config.written?
        if Apache::Config.disabled?
          puts file.foreground(:blue)
        else
          puts file.foreground(:green)
        end
        puts output
      end
    end
  end

  desc "List all possible environments"
  task :environments do
    puts get_environments * "\n"
  end

  desc "Set the default environment (currently #{get_default_environment || 'nil'})"
  task :default, :environment do |t, args|
    need_environment if !args[:environment]

    if get_environments.include?(args[:environment])
      File.open('.environment', 'w') { |fh| fh.puts args[:environment] }
      puts "Calls to apache:create will now use #{args[:environment]} when you don't specify the environment."
    else
      puts "You need to specify a valid default environment. Here are the possibilities:"
      Rake::Task['apache:environments'].invoke
    end
  end
end
