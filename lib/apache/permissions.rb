module Apache
  module Permissions
    def deny_from_all
      order :deny, :allow
      deny :from_all
    end

    def allow_from_all
      order :allow, :deny
      allow :from_all
    end

    def order(*args)
      self << "Order #{args * ','}"
    end

    def default_restrictive!
      directory '/' do
        options :follow_sym_links
        allow_override :none
        deny_from_all
      end
    end

    def no_htfiles!
      files_match '^\.ht' do
        deny_from_all
        satisfy :all
      end
    end

    alias :order! :order
  end
end
