module Apache
  module MPM
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
