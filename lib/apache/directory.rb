module Apache
  module Directories
    def options(*opt)
      opt = opt.collect { |o| apachify(o) }
      self << "Options #{opt * " "}"
    end
  end
end
