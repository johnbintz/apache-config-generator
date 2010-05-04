$LOAD_PATH << 'lib'

require 'apache'
require 'spec/rake/spectask'

namespace :apache do
  desc "Generate the configs"
  task :generate, :path do |t, args|
    Dir[File.join(args[:path], '**', '*.rb')].each do |file|
      require file
    end
  end
end

namespace :spec do
  desc "Run RCov tests"
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList['spec/*.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec']
  end
end
