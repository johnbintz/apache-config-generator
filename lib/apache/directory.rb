module Apache
  module Directories
    def options(*opt)
      self << "Options #{apachify(opt) * " "}"
    end

    def index_options(*opt)
      self << "IndexOptions #{apachify(opt) * " "}"
    end
  end
end
