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

    def timeout(t)
      self << "Timeout #{t}"
    end

    def comment(c)
      out = [ '' ]
      case c
        when String
          out += c.split("\n")
        when Array
          out += c
      end
      out << ''
      self + out.collect { |line| "# #{line.strip}".strip }
    end

    def script_alias(uri, path)
      directory? path
      self << %{ScriptAlias #{quoteize(uri, path) * ' '}}
    end

    alias :script_alias! :script_alias

    def add_type!(mime, extension, options = {})
      self << "AddType #{mime} #{extension}"
      options.each do |type, value|
        self << "Add#{type.to_s.capitalize} #{value} #{extension}"
      end
    end

    def apache_include(*opts)
      self << "Include #{opts * " "}"
    end

    def apache_alias(*opts)
      self << "Alias #{quoteize(*opts) * " "}"
    end

    def set_header(hash)
      hash.each do |key, value|
        output = "Header set #{quoteize(key)}"
        case value
          when String, Symbol
            output += " #{quoteize(value)}"
          when Array
            output += " #{quoteize(value.first)} #{value.last}"
        end
        self << output
      end
    end
  end
end
