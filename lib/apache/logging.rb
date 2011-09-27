module Apache
  # Methods to handle logging configuration are defined here.
  #
  # For each of the four main log types (Custom, Error, Script, and Rewrite), the following two methods are created:
  #
  # * (type)_log: A non-rotated log file
  # * rotate_(type)_log: A rotated log file
  #
  # Non-rotated logs work as such:
  #  custom_log "/path/to/log/file.log", :common #=> CustomLog "/path/to/log/file.log" common
  #
  # Rotated logs work as such:
  #  rotate_custom_log "/path/to/log/file-%Y%m%d.log", 86400, :common
  #    #=> CustomLog "|/path/to/rotatelogs /path/to/log/file-%Y%m%d.jpg 86400" common
  #
  # Both variations check to make sure the log file diretory exists during generation.
  # The rotate_ variations need @rotate_logs_path set to work.
  module Logging
    class << self
      def log_paths
        @log_paths ||= {}
      end

      def reset!
        @log_paths = {}
      end
    end

    [ :custom, :error, :script, :rewrite ].each do |type|
      class_eval <<-EOT
        def #{type}_log(*opts)
          handle_log :tag => '#{type.to_s.capitalize}Log',
                     :path => opts.first,
                     :additional_options => opts[1..-1],
                     :type => :#{type}
        end

        def rotate_#{type}_log(*opts)
          handle_log :tag => '#{type.to_s.capitalize}Log',
                     :path => opts.first,
                     :real_path => rotatelogs(*opts[0..1]),
                     :additional_options => opts[2..-1],
                     :type => :#{type}

        end
      EOT
    end

    def combined_log_format(name = 'combined')
      log_format '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"', name.to_sym
    end

    def common_log_format(name = 'common')
      log_format '%h %l %u %t \"%r\" %>s %b', name.to_sym
    end

    private
      def handle_log(info)
        writable? (path = info[:path])

        real_path = (info[:real_path] || path).quoteize

        (Apache::Logging.log_paths[info[:type]] ||= []) << path

        self << "#{info[:tag]} #{[real_path, info[:additional_options]].flatten * " "}"
      end
  end
end
