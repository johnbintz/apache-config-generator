module Apache
  module Logging
    def error_log(*opts)
      handle_log 'ErrorLog', opts.first, opts.first, opts[1..-1]
    end

    def custom_log(*opts)
      handle_log 'CustomLog', opts.first, opts.first, opts[1..-1]
    end

    def rotate_custom_log(*opts)
      handle_log 'CustomLog', opts.first, quoteize(rotatelogs(*opts[0..1])), opts[2..-1]
    end

    def rotate_error_log(*opts)
      handle_log 'ErrorLog', opts.first, quoteize(rotatelogs(*opts[0..1])), opts[2..-1]
    end

    def rotate_script_log(*opts)
      handle_log 'ScriptLog', opts.first, quoteize(rotatelogs(*opts[0..1])), opts[2..-1]
    end

    def combined_log_format(name = 'combined')
      log_format '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"', name.to_sym
    end

    def common_log_format(name = 'common')
      log_format '%h %l %u %t \"%r\" %>s %b', name.to_sym
    end

    private
      def handle_log(tag, path, real_path, *opts)
        writable? path
        self << "#{tag} #{[real_path, opts].flatten * " "}"
      end
  end
end
