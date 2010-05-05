module Apache
  module Performance
    def activate_keepalive(options)
      self << "KeepAlive On"
      options.each do |option, value|
        case option
          when :requests
            self << "MaxKeepAliveRequests #{value}"
          when :timeout
            self << "KeepAliveTimeout #{value}"
        end
      end
    end

    def prefork_config(&block)
      self + Apache::MPM::Prefork.build(&block)
    end
  end
end
