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

