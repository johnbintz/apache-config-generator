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
  end
end
