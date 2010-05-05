module Apache
  module Master
    def modules(*modules, &block)
      @config += Modules.build(*modules, &block)
    end

    def runner(user, group = nil)
      user! user
      group! group if group
    end

    def passenger(ruby_root, ruby_version, passenger_version)
      load_module 'passenger_module', "#{ruby_root}/lib/ruby/gems/#{ruby_version}/gems/passenger-#{passenger_version}/ext/apache2/mod_passenger.so"
      passenger_root "#{ruby_root}/lib/ruby/gems/#{ruby_version}/gems/passenger-#{passenger_version}"
      passenger_ruby "#{ruby_root}/bin/ruby"
    end

    def enable_gzip!
      directory '/' do
        add_output_filter_by_type! :DEFLATE, 'text/html', 'text/plain', 'text/css', 'text/javascript', 'application/javascript'
        browser_match! '^Mozilla/4', "gzip-only-text/html"
        browser_match! '^Mozilla/4\.0[678]', "no-gzip"
        browser_match! '\bMSIE', '!no-gzip', '!gzip-only-text/html'
      end
    end
  end
end
