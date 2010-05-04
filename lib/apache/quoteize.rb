module Apache
  module Quoteize
    def quoteize(*args)
      args.collect do |arg|
        case arg
          when Symbol
            arg.to_s.gsub('_', ' ')
          else
            %{"#{arg}"}
        end
      end
    end
  end
end
