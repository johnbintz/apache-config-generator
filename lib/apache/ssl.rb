module Apache
  module SSL
    def enable_ssl_engine(options = {})
      self << ""
      self << "SSLEngine on"
      options.each do |key, value|
        value = quoteize(value).first
        case key
          when :certificate_file, :certificate_key_file
            self << "SSL#{key.apachify} #{value}"
          when :ca_certificate_file
            self << "SSLCACertificateFile #{value}"
        end
      end
      self << ""
    end
  end
end
