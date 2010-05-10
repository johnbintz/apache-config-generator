module Apache
  # Add quotes around parameters as needed
  module Quoteize
    # Add quotes around most parameters, and don't add quotes around Symbols
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
