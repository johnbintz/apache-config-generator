module Apache
  module MPM
    # Set up the Prefork MPM
    #
    # The block you pass in to this can take the following methods:
    # * start(num) - StartServers
    # * spares(min, max) - Min and MaxSpareServers
    # * limit(num) - ServerLimit
    # * clients(num) - MaxClients
    # * max_requests(num) - MaxRequestsPerChild
    def prefork_config(&block)
      self + Apache::MPM::Prefork.build(&block)
    end

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
