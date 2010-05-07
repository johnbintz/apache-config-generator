module Apache
  module Logging
    [ :custom, :error, :script, :rewrite ].each do |type|
      class_eval <<-EOT
        def #{type}_log(*opts)
          handle_log '#{type.to_s.capitalize}Log', opts.first, opts.first, opts[1..-1]
        end

        def rotate_#{type}_log(*opts)
          handle_log '#{type.to_s.capitalize}Log', opts.first, quoteize(rotatelogs(*opts[0..1])), opts[2..-1]
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
      def handle_log(tag, path, real_path, *opts)
        writable? path
        self << "#{tag} #{[real_path, opts].flatten * " "}"
      end
  end
end
