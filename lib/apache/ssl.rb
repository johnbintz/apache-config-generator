module Apache
  module SSL
    def enable_ssl_engine(options = {})
      self + [ '', "SSLEngine on" ]
      options.each do |key, value|
        value = value.quoteize
        case key
          when :certificate_file, :certificate_key_file
            self << "SSL#{key.apachify} #{value}"
          when :ca_certificate_file
            self << "SSLCACertificateFile #{value}"
        end
      end
      blank_line!
    end
  end
end
