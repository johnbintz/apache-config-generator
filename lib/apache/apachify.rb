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

  alias :blockify :quoteize

  def headerize
    "#{self.quoteize}"
  end

  def replace_placeholderize(opts)
    self.gsub(%r{%\{([^\}]+)\}}) do |match|
      key = $1.downcase.to_sym
      opts[key] || ''
    end
  end
end

# Ruby symbols
class Symbol
  include Apache::Apachify

  # Turn this into an option for IndexOptions
  def optionify
    output = self.apachify
    output = "-#{output[3..-1]}" if self.to_s[0..3] == 'not_'
    output
  end

  def quoteize
    self.to_s.gsub('_', ' ')
  end

  def blockify
    self.to_s
  end

  def headerize
    "#{self.quoteize}"
  end
end

class Fixnum
  def quoteize; self; end
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

  def blockify
    self.quoteize * " "
  end

  alias :commentize :to_a

  def headerize
    "#{self.first.quoteize} #{self.last}"
  end

  def rewrite_cond_optionify
    self.collect do |opt|
      {
        :or => 'OR',
        :case_insensitive => 'NC',
        :no_vary => 'NV'
      }[opt]
    end
  end

  def rewrite_option_listify
    (!self.empty?) ? "[#{self * ','}]" : nil
  end
end

# Ruby hashes
class Hash
  REWRITE_RULE_CONDITIONS = {
    :last => 'L',
    :forbidden => 'F',
    :no_escape => 'NE',
    :redirect => lambda { |val| val == true ? 'R' : "R=#{val}" },
    :pass_through => 'PT',
    :preserve_query_string => 'QSA',
    :query_string_append => 'QSA',
    :env => lambda { |val| "E=#{val}" }
  }

  def rewrite_rule_optionify
    self.collect do |key, value|
      what = REWRITE_RULE_CONDITIONS[key]
      what = what.call(value) if what.kind_of? Proc
      what
    end.compact.sort
  end
end
