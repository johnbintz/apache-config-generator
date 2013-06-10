module Apache
  # Create lists of modules to load in the Apache 2.2 style (with LoadModule only)
  class Modules
    class << self
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

        modules.each { |mod| add_module(mod) }
        self.instance_eval(&block) if block

        [ '' ] + @modules + [ '' ]
      end

      def add_module(method, *args)
        module_name = "#{method}_module"
        module_path = args[0] || "modules/mod_#{method}.so"
        @modules << [ 'LoadModule', *[ module_name, module_path ].quoteize ] * " "
      end

      # The method name becomes the module core name
      def method_missing(method, *args)
        add_module(method, *args)
      end
    end
  end
end
