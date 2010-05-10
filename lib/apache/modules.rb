require 'apache/quoteize'

module Apache
  # Create lists of modules to load in the Apache 2.2 style (with LoadModule only)
  class Modules
    class << self
      include Apache::Quoteize

      attr_accessor :modules

      # Reset the list of modules to output
      def reset!
        @modules = []
      end

      # Build a block of LoadModule commands
      #
      #  Apache::Modules.build(:expires, :headers) do
      #    funky "/path/to/funky/module.so"
      #  end
      #
      # becomes:
      #
      #  LoadModule "expires_module" "modules/mod_expires.so"
      #  LoadModule "headers_module" "modules/mod_headers.so"
      #  LoadModule "funky_module" "/path/to/funky/module.so"
      def build(*modules, &block)
        reset!

        modules.each { |m| self.send(m) }
        self.instance_eval(&block) if block

        [ '' ] + @modules + [ '' ]
      end

      # The method name becomes the module core name
      def method_missing(method, *args)
        module_name = "#{method}_module"
        module_path = args[0] || "modules/mod_#{method}.so"
        @modules << [ 'LoadModule', *quoteize(module_name, module_path) ] * " "
      end
    end
  end
end
