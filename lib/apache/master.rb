module Apache
  module Quoteize
    def quoteize(*args)
      args.collect { |a| %{"#{a}"} }
    end
  end

  module Master
    def modules(&block)
      @config << Modules.build(&block)
    end

    def indent(string)
      " " * (@indent * 2) + string
    end

    def block_methods(*methods)
      methods.each do |method|
        self.class.class_eval <<-EOT
          def #{method}(name = nil, &block)
            tag_name = apachify("#{method}")
            start = [ tag_name ]
            start << '"' + name + '"' if name
            start = start.uniq.join(' ')

            @config << "" if (@indent == 0)
            @config << indent("<" + start + ">")
            @indent += 1
            self.instance_eval(&block)
            @indent -= 1
            @config << indent("</" + tag_name + ">")
          end
        EOT
      end
    end

    def method_missing(method, *args)
      @config << indent([ apachify(method), *quoteize(*args) ] * ' ')
    end

    def runner(user, group = nil)
      @config << indent("User #{user}")
      @config << indent("Group #{group}") if group
    end

    def deny_from_all
      @config << indent("Order deny,allow")
      @config << indent("Deny from all")
    end

    def allow_from_all
      @config << indent("Order allow,deny")
      @config << indent("Allow from all")
    end

    private
      def apachify(name)
        name = name.to_s
        case name
          when true
          else
            name.split("_").collect(&:capitalize).join
        end
      end
  end

  class Modules
    class << self
      include Apache::Quoteize

      def build(&block)
        @modules = []

        self.instance_eval(&block)

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
