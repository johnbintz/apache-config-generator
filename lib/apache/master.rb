module Apache
  # Options that aren't specific to a particular purpose go here. Once enough like methods for a
  # particular purpose exist, break them out into a separate module.
  module Master
    # Build a module list.
    # Wraps around Modules.build
    def modules(*modules, &block)
      @config += Modules.build(*modules, &block)
    end

    # Add a User/Group block
    #  runner('www', 'www-data') #=>
    #    User www
    #    Group www-data
    def runner(user, group = nil)
      user! user
      group! group if group
    end

    # Enable Passenger on this server
    #
    # This assumes that Passenger was installed via the gem. This may or may not work for you, but it works for me.
    def passenger(ruby_root, ruby_version, passenger_version)
      load_module 'passenger_module', "#{ruby_root}/lib/ruby/gems/#{ruby_version}/gems/passenger-#{passenger_version}/ext/apache2/mod_passenger.so"
      passenger_root "#{ruby_root}/lib/ruby/gems/#{ruby_version}/gems/passenger-#{passenger_version}"
      passenger_ruby "#{ruby_root}/bin/ruby"
    end

    # Enable gzip compression server-wide on pretty much everything that can be gzip compressed
    def enable_gzip!
      directory '/' do
        add_output_filter_by_type! :DEFLATE, 'text/html', 'text/plain', 'text/css', 'text/javascript', 'application/javascript'
        browser_match! '^Mozilla/4', "gzip-only-text/html"
        browser_match! '^Mozilla/4\.0[678]', "no-gzip"
        browser_match! '\bMSIE', '!no-gzip', '!gzip-only-text/html'
      end
    end

    # Set the TCP timeout. Defined here to get around various other timeout methods.
    def timeout(t)
      self << "Timeout #{t}"
    end

    # Add a comment to the Apache config. Can pass in either a String or Array of comment lines.
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

    # Create a ScriptAlias, checking to make sure the filesystem path exists.
    def script_alias(uri, path)
      directory? path
      self << %{ScriptAlias #{quoteize(uri, path) * ' '}}
    end

    alias :script_alias! :script_alias

    # Add a MIME type, potentially also adding handlers and encodings
    #  add_type! 'text/html', '.shtml', :handler => 'server-parsed'
    #  add_type! 'text/html', '.gz', :encoding => 'gzip'
    def add_type!(mime, extension, options = {})
      self << "AddType #{mime} #{extension}"
      options.each do |type, value|
        self << "Add#{type.to_s.capitalize} #{value} #{extension}"
      end
    end

    # Include other config files or directories.
    # Used to get around reserved Ruby keyword.
    def apache_include(*opts)
      self << "Include #{opts * " "}"
    end

    # Alias a URL to a directory in the filesystem.
    # Used to get around reserved Ruby keyword.
    def apache_alias(*opts)
      self << "Alias #{quoteize(*opts) * " "}"
    end

    # Set multiple headers to be delivered for a particular section
    #  set_header 'Content-type' => 'application/octet-stream',
    #             'Content-disposition' => [ 'attachment', 'env=only-for-downloads' ] #=>
    #  Header set "Content-type" "application/octet-stream"
    #  Header set "Content-dispoaition" "attachment" env=only-for-downloads
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
