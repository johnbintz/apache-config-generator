module Apache
  module Apachify
    # Apachify a string
    #
    # Split the provided name on underscores and capitalize the individual parts
    # Certain character strings are capitalized to match Apache directive names:
    # * Cgi => CGI
    # * Ssl => SSL
    # * Ldap => LDAP
    def apachify
      self.to_s.split("_").collect { |part|
        part.capitalize!

        case part
          when 'Ssl', 'Cgi', 'Ldap', 'Url'; part.upcase
          when 'Etag'; 'ETag'
          else; part
        end
      }.join
    end
  end
end

