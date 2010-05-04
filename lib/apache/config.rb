Dir[File.join(File.dirname(__FILE__), '*.rb')].each { |f| require f }

module Apache
  class Config
    class << self
      attr_accessor :line_indent, :config

      include Apache::Master
      include Apache::Quoteize
      include Apache::Permissions

      def build(target = nil, &block)
        reset!

        self.instance_eval(&block)
      end

      # Reset the current settings
      def reset!
        @config = []
        @line_indent = 0
      end

      # Indent the string by the current @line_indent level
      def indent(string)
        " " * (@line_indent * 2) + string
      end

      # Add the string to the current config
      def <<(string)
        @config << indent(string)
      end

      # Apachify a string
      #
      # Split the provided name on underscores and capitalize the individual parts
      def apachify(name)
        name.to_s.split("_").collect(&:capitalize).join
      end

      # Handle options that aren't specially handled
      def method_missing(method, *args)
        if method.to_s[-1..-1] == "!"
          method = method.to_s[0..-2].to_sym
        else
          args = *quoteize(*args)
        end

        self << [ apachify(method), *args ] * ' '
      end

      # Handle creating block methods
      def block_methods(*methods)
        methods.each do |method|
          self.class.class_eval <<-EOT
            def #{method}(*name, &block)
              blockify(apachify("#{method}"), name, &block)
            end
          EOT
        end
      end

      # Handle the blockification of a provided block
      def blockify(tag_name, name, &block)
        start = [ tag_name ]

        case name
          when String
            start << quoteize(name).first if name
          when Array
            start << (quoteize(*name) * " ") if name
        end

        start = start.join(' ')

        self << "" if (@indent == 0)
        self << "<#{start}>"
        @line_indent += 1
        self.instance_eval(&block)
        @line_indent -= 1
        self << "</#{tag_name}>"
      end
    end

    block_methods :if_module, :directory, :virtual_host
  end
end
