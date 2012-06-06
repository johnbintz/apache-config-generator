module Apache
  module Proxy
    def proxy(*args, &block)
      blockify('proxy'.apachify, *args, &block)
    end
  end
end

