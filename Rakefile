$LOAD_PATH << 'lib'

require 'apache'
require 'spec/rake/spectask'
require 'sdoc'
require 'sdoc_helpers/markdown'
require 'echoe'

namespace :apache do
  desc "Generate the configs"
  task :generate, :path do |t, args|
    Dir[File.join(args[:path], '**', '*.rb')].each do |file|
      require file
    end
  end
end

Echoe.new('apache-config-generator') do |p|
  p.author = "John Bintz"
  p.summary = "A Ruby DSL for programmatically generating Apache configs"
  p.ignore_pattern = [ 'spec/**/*', 'test/**/*', 'docs/**/*' ]
  p.executable_pattern = [ 'bin/**/*' ]
  p.runtime_dependencies = [ 'rainbow' ]
end

namespace :spec do
  desc "Run RCov tests"
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList['spec/*.rb']
    t.rcov = true
    t.rcov_opts = ['--exclude', 'spec', '--exclude', 'gems']
    t.spec_opts = ['-b']
  end
end

Rake::RDocTask.new do |rdoc|
  rdoc.template = 'direct'
  rdoc.rdoc_files.add('lib', 'README.rdoc')
  rdoc.main = 'README.rdoc'
  rdoc.rdoc_dir = 'docs'
end
