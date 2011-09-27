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

