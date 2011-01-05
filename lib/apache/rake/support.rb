require 'yaml'
require 'fileutils'
require 'apache/hash'

module Apache
  module Rake
    module Support
      def config
        if !@config
          @config = YAML.load_file('config.yml').to_sym_keys
          config_paths!

          class << @config
            def [](which)
              if which == :dest_path
                print "config[:dest_path] is deprecated.".foreground(:red).bright
                puts  " Use config[:destination_path] instead.".foreground(:red)

                self[:destination_path]
              else
                super
              end
            end
          end
        end

        @config
      end

      def config_paths!
        [ :source, :destination, :symlink ].each do |which|
          begin
            @config[:"#{which}_path"] = File.expand_path(@config[which])
          rescue StandardError
            puts "#{which.to_s.bright} is not defined in the configuration file.".foreground(:red)
            exit 1
          end
        end
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

      def symlink_configs!
        raise Errno::ENOENT if !File.directory?(config[:destination_path])

        FileUtils.rm_rf(config[:symlink_path])
        FileUtils.mkdir_p(config[:symlink_path])

        Dir[File.join(config[:destination_path], '**/*')].find_all { |file| File.file?(file) }.each do |file|
          if line = File.read(file).first
            if !line['# disabled']
              target = file.gsub(config[:destination_path], config[:symlink_path])
              FileUtils.mkdir_p(File.split(target).first)
              FileUtils.ln_sf(file, target)
            end
          end
        end
      end
    end
  end
end
