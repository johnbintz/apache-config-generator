module Apache
  module Permissions
    def deny_from_all
      order :deny, :allow
      deny :from_all
    end

    alias :deny_from_all! :deny_from_all

    def allow_from_all
      order :allow, :deny
      allow :from_all
    end

    alias :allow_from_all! :allow_from_all

    def allow_from(where)
      allow "from_#{where}".to_sym
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

    def basic_authentication(zone, users_file, requires)
      exist? users_file
      auth_type :basic
      auth_name zone
      auth_user_file users_file
      requires.each do |type, values|
        apache_require type, *values
      end
    end

    alias :basic_authentication! :basic_authentication

    def ldap_authentication(zone, url, requires)
      auth_type :basic
      auth_name zone
      auth_basic_provider :ldap
      authz_ldap_authoritative :on
      auth_ldap_url url
      requires.each do |type, values|
        apache_require type, *values
      end
    end

    alias :ldap_authentication! :ldap_authentication

    def apache_require(*opts)
      self << "Require #{opts * " "}"
    end
  end
end
