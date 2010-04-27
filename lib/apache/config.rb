require 'apache/master'

module Apache
  class Config
    class << self
      include Apache::Master
      include Apache::Quoteize

      def build(target, &block)
        @config = []
        @indent = 0

        self.instance_eval(&block)

        puts @config * "\n"

        #File.open(target, 'w') { |f| f.puts @config * "\n" }
      end
    end

    block_methods :if_module, :directory, :virtual_host
  end
end
