module Apache
  module Quoteize
    def quoteize(*args)
      args.collect { |a| %{"#{a}"} }
    end
  end

  module Master
    def modules(*modules, &block)
      @config << Modules.build(*modules, &block)
    end

    def indent(string)
      " " * (@indent * 2) + string
    end

    def block_methods(*methods)
      methods.each do |method|
        self.class.class_eval <<-EOT
          def #{method}(*name, &block)
            blockify(apachify("#{method}"), name, &block)
          end
        EOT
      end
    end

    def blockify(tag_name, name, &block)
      start = [ tag_name ]

      case name
        when String
          start << quoteize(name).first if name
        when Array
          start << (quoteize(*name) * " ") if name
      end

      start = start.uniq.join(' ')

      @config << "" if (@indent == 0)
      @config << indent("<" + start + ">")
      @indent += 1
      self.instance_eval(&block)
      @indent -= 1
      @config << indent("</" + tag_name + ">")
    end

    def method_missing(method, *args)
      if method.to_s[-1..-1] == "!"
        method = method.to_s[0..-2].to_sym
      else
        args = *quoteize(*args)
      end

      @config << indent([ apachify(method), *args ] * ' ')
    end

    def runner(user, group = nil)
      user! user
      group! group if group
    end

    def deny_from_all
      order! "deny,allow"
      deny! "from all"
    end

    def allow_from_all
      order! "allow,deny"
      allow! "from all"
    end

    def passenger(ruby_root, ruby_version, passenger_version)
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
