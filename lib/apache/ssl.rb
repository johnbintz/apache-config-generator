module Apache
  module SSL
    def enable_ssl_engine(options = {})
      self << ""
      self << "SSLEngine on"
      options.each do |k, v|
        case k
          when :certificate_file, :certificate_key_file
            self << "SSL#{apachify(k)} #{quoteize(v).first}"
          when :ca_certificate_file
            self << "SSLCACertificateFile #{quoteize(v).first}"
        end
      end
      self << ""
    end
  end
end
