module Apache
  module Logging
    def error_log(*opts)
      writable? opts.first
      self << "ErrorLog #{opts * " "}"
    end

    def custom_log(*opts)
      writable? opts.first
      self << "CustomLog #{opts * " "}"
    end

    def combined_log_format(name = 'combined')
      log_format '%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"', name.to_sym
    end

    def common_log_format(name = 'common')
      log_format '%h %l %u %t \"%r\" %>s %b', name.to_sym
    end
  end
end
