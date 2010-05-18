module Apache
  # Methods to handle directory settings
  module Directories
    # Create an Options directive
    #
    # The options passed into this method are Apachified:
    #  options :exec_cgi, :follow_sym_links #=> Options ExecCGI FollowSymLinks
    def options(*opt)
      create_options_list('Options', *opt)
    end

    # Create an IndexOptions directive
    #
    # The options passed into this method are Apachified:
    #  index_options :fancy_indexing, :suppress_description #=> IndexOptions FancyIndexing SuppressDescription
    def index_options(*opt)
      create_options_list('IndexOptions', *opt)
    end

    private
      def create_options_list(tag, *opt)
        self << "#{tag} #{opt.collect(&:optionify) * " "}"
      end
  end
end
