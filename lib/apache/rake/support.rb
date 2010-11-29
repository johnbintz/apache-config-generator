require 'yaml'
require 'fileutils'

module Apache
  module Rake
    module Support
      def config
        @config ||= Hash[YAML.load_file('config.yml').collect { |k,v| [ k.to_sym, v ] }]
      end

      def get_environments
        config[:source_path] = File.expand_path(config[:source])

        Dir[File.join(config[:source_path], '**', '*.rb')].collect { |file|
          File.readlines(file).find_all { |line| line[%r{(if_environment|build_if)}] }.collect { |line| line.scan(%r{:[a-z_]+}) }
        }.flatten.uniq.sort.collect { |name| name[1..-1] }
      end

      def get_default_environment
        File.read('.environment').strip rescue nil
      end

      def need_environment
        puts "You need to specify an environment. Available environments:"
        puts
        puts get_environments.collect { |env| "rake apache:create[#{env}]" } * "\n"
        puts
        puts "Additionally, you can set a default environment for this server:"
        puts
        puts "rake apache:default[#{get_environments.first}]"
        exit 1
      end
    end
  end
end
