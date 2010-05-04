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

    def order(*args)
      self << "Order #{args * ','}"
    end

    alias :order! :order
  end
end
