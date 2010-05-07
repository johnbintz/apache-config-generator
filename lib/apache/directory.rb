module Apache
  module Directories
    def options(*opt)
      create_options_list('Options', *opt)
    end

    def index_options(*opt)
      create_options_list('IndexOptions', *opt)
    end

    private
      def create_options_list(tag, *opt)
        self << "#{tag} #{apachify(opt) * " "}"
      end
  end
end
