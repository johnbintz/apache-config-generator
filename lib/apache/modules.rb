require 'apache/quoteize'

module Apache
  class Modules
    class << self
      include Apache::Quoteize

      def build(*modules, &block)
        @modules = []

        modules.each { |m| self.send(m) }
        self.instance_eval(&block) if block

        @modules
      end

      def method_missing(method, *args)
        module_name = "#{method}_module"
        module_path = args[0] || "modules/mod_#{method}.so"
        @modules << [ 'LoadModule', *quoteize(module_name, module_path) ] * " "
      end
    end
  end
end
