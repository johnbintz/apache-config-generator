module Apache
  # Configure server access permissions
  module Permissions
    # Shortcut for denying all access to a block
    def deny_from_all
      order :deny, :allow
      deny :from_all
    end

    alias :deny_from_all! :deny_from_all

    # Shortcut for allowing all access to a block
    def allow_from_all
      order :allow, :deny
      allow :from_all
    end

    alias :allow_from_all! :allow_from_all

    # Define IP block restrictions
    #
    #  allow_from '127.0.0.1' #=> Allow from "127.0.0.1"
    def allow_from(*where)
      self << "Allow from #{quoteize(*where) * " "}"
    end

    # Specify default access order
    #
    #  order :allow, :deny #=> Order allow,deny
    def order(*args)
      self << "Order #{args * ','}"
    end

    alias :order! :order

    # Set up default restrictive permissions
    def default_restrictive!
      directory '/' do
        options :follow_sym_links
        allow_override :none
        deny_from_all
      end
    end

    # Block all .ht* files
    def no_htfiles!
      files_match %r{^\.ht} do
        deny_from_all
        satisfy :all
      end
    end

    # Set up basic authentication
    #
    # Check to make sure the defined users_file exists
    #
    #  basic_authentication "My secret", '/my.users', 'valid-user' => true
    #  basic_authentication "My other secret", '/my.users', :user => [ :john ]
    def basic_authentication(zone, users_file, requires = {})
      exist? users_file
      auth_type :basic
      auth_name zone
      auth_user_file users_file
      requires.each do |type, values|
        apache_require type, *values
      end
    end

    alias :basic_authentication! :basic_authentication

    # Set up LDAP authentication
    def ldap_authentication(zone, url, requires = {})
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

    # Create an Apache require directive.
    # Used to get around Ruby reserved word.
    def apache_require(*opts)
      self << "Require #{opts * " "}"
    end
  end
end
