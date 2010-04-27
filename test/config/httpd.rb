Apache::Config.build('httpd.conf') do
  server_root '/var/html/apache'

  modules :expires, :headers
  modules :usertrack, :rewrite
  load_module "php5_module", "modules/libphp5.so"

  passenger '/var/html/ree', '1.8', '2.2.11'

  if_module "!mpm_netware" do
    runner 'webby', 'opoadm'
  end

  directory '/' do
    options! 'FollowSymLinks'
    allow_override! 'None'
    deny_from_all
  end

  virtual_host '127.0.0.1:80', '127.0.0.1:81' do
    directory '/' do
      allow_from_all
    end
  end
end
