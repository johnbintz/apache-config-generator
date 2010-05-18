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

# Ruby strings
class String
  include Apache::Apachify

  alias :optionify :apachify
end

# Ruby symbols
class Symbol
  include Apache::Apachify

  def optionify
    output = self.apachify
    output = "-#{output[4..-1].apachify}" if self.to_s[0..3] == 'not_'
    output
  end
end

# Ruby arrays
class Array
  # Apachify all the elements within this array
  def apachify
    self.collect(&:apachify)
  end
end
