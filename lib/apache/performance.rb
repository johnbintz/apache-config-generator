module Apache
  # Options to adjust server performance beyond MPM settings
  module Performance
    # Activate KeepAlive, optionally tweaking max requests and timeout
    #
    #  activate_keepalive :requests => 100, :timeout => 5 #=>
    #    KeepAlive on
    #    MaxKeepAliveRequests 100
    #    KeepAliveTimeout 5
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
  end
end
