module Apache
  module MPM
    # Set up the Prefork MPM
    #
    #  prefork_config do
    #    start 5
    #    spares 5, 20
    #    limit 100
    #    clients 100
    #    max_requests 1000
    #  end
    #
    # becomes:
    #
    #  StartServers 5
    #  MinSpareServers 5
    #  MaxSpareServers 20
    #  ServerLimit 100
    #  MaxClients 100
    #  MaxRequestsPerChild 1000
    #
    def prefork_config(&block)
      self + Apache::MPM::Prefork.build(&block)
    end

    # Builder for Prefork MPM
    # See Apache::MPM::prefork_config for usage.
    class Prefork
      class << self
        def build(&block)
          @config = ['', '# Prefork config', '']

          self.instance_eval(&block)

          @config
        end

        def method_missing(method, *opts)
          if which = {
            :start => 'StartServers',
            :spares => [ 'MinSpareServers', 'MaxSpareServers' ],
            :limit => 'ServerLimit',
            :clients => 'MaxClients',
            :max_requests => 'MaxRequestsPerChild'
          }[method]
            case which
              when String
                @config << "#{which} #{opts * " "}"
              when Array
                which.each do |w|
                  @config << "#{w} #{opts.shift}"
                end
            end
          end
        end
      end
    end
  end
end
