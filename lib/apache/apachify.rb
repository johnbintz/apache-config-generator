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

  def commentize
    self.split("\n")
  end

  def quoteize
    %{"#{self}"}
  end
end

# Ruby symbols
class Symbol
  include Apache::Apachify

  # Turn this into an option for IndexOptions
  def optionify
    output = self.apachify
    output = "-#{output[4..-1].apachify}" if self.to_s[0..3] == 'not_'
    output
  end

  def quoteize
    to_s.gsub('_', ' ')
  end
end

class Fixnum
  def quoteize; to_s; end
end

# Ruby arrays
class Array
  # Apachify all the elements within this array
  def apachify
    self.collect(&:apachify)
  end

  def quoteize
    self.collect(&:quoteize)
  end

  def quoteize!
    self.collect!(&:quoteize)
  end

  alias :commentize :to_a
end
