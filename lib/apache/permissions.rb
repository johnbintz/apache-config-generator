module Apache
  module Permissions
    def deny_from_all
      order! "deny,allow"
      deny! "from all"
    end

    def allow_from_all
      order! "allow,deny"
      allow! "from all"
    end
  end
end
