Apache::Config.build('httpd.conf') do
  server_root '/var/html/apache'

  modules do
    expires
    headers
  end

  passenger_root '/var/html/ree/lib/ruby/gems/1.8/gems/passenger-2.2.11'
  passenger_ruby '/var/html/ree/bin/ruby'

  if_module "!mpm_netware" do
    runner 'webby', 'opoadm'
  end

  directory '/' do
    options 'FollowSymLinks'
    allow_override 'None'
    deny_from_all
  end

  virtual_host '127.0.0.1:80' do
    directory '/' do
      allow_from_all
    end
  end
end
