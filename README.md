# Apache Config Generator

Programmatically construct your Apache configuration using a powerful DSL built in Ruby.

## Installation

`gem install apache-config-generator`

## Usage

Run `apache-configurator <directory>` to create a new directory to hold your config files.
A Rakefile and config.yml file will also be generated.

## Building a config file

Configs center around the Apache::Config.build method:

		Apache::Config.build('sites-available/my-site.conf') do
			server_name 'my-cool-website.cool.wow'
			document_root '/var/www/my-cool-website'

			directory '/' do
				options :follow_sym_links, :indexes
				allow_from_all
			end

			location_match %r{^/secret} do
				deny_from_all

				basic_authentication "My secret", '/etc/apache2/users/global.users', :user => :john
				satisfy :any
			end
		end
