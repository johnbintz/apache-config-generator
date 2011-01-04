Autotest.add_discovery { "rspec2" }

Autotest.add_hook(:initialize) do |at|
  at.add_exception(%r{^./test/.*})
end
  
