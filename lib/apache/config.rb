require 'apache/master'
require 'apache/permissions'

module Apache
  class Config
    class << self
      include Apache::Master
      include Apache::Quoteize
      include Apache::Permissions

      def build(target, &block)
        @config = []
        @indent = 0

        self.instance_eval(&block)

        puts @config * "\n"

        #File.open(target, 'w') { |f| f.puts @config * "\n" }
      end

      def indent(string)
        " " * (@indent * 2) + string
      end

      def <<(string)
        @config << indent(string)
      end
    end

    block_methods :if_module, :directory, :virtual_host
  end
end
