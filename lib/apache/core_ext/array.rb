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

