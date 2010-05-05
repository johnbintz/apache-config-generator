Dir[File.join(File.dirname(__FILE__), '*.rb')].each { |f| require f }

module Apache
  class Config
    class << self
      attr_accessor :line_indent, :config

      include Apache::Master
      include Apache::Quoteize
      include Apache::Permissions
      include Apache::Directories
      include Apache::Logging

      def build(target = nil, &block)
        reset!

        self.instance_eval(&block)

        File.open(target, 'w') { |f| f.puts @config * "\n" } if target

        @config
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
        name.to_s.split("_").collect(&:capitalize).join.gsub('Ssl', 'SSL')
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

      def if_module(mod, &block)
        blockify(apachify('if_module'), "#{mod}_module".to_sym, &block)
      end

      def directory(dir, &block)
        directory? dir
        blockify(apachify('directory'), dir, &block)
      end

      # Handle the blockification of a provided block
      def blockify(tag_name, name, &block)
        start = [ tag_name ]

        case name
          when String
            start << quoteize(name).first
          when Array
            start << (quoteize(*name) * " ")
          when Symbol
            start << name.to_s
        end

        start = start.join(' ')

        self << "" if (@line_indent == 0)
        self << "<#{start}>"
        @line_indent += 1
        self.instance_eval(&block)
        @line_indent -= 1
        self << "</#{tag_name}>"
      end

      def apache_include(*opts)
        self << "Include #{opts * " "}"
      end

      private
        def writable?(path)
          if !File.directory? File.split(path).first
            puts "[warn] #{path} may not be writable!"
          end
        end

        def directory?(path)
          if !File.directory? path
            puts "[warn] #{path} does not exist!"
          end
        end

    end

    block_methods :virtual_host, :files_match
  end
end
