require File.expand_path("../lib/apache/version", __FILE__)

Gem::Specification.new do |s|
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=

  s.name = %q{apache-config-generator}
  s.version = Apache::VERSION
  s.platform    = Gem::Platform::RUBY

  s.authors = ["John Bintz"]
  s.description = %q{A Ruby DSL for programmatically generating Apache configs}
  s.summary = %q{A Ruby DSL for programmatically generating Apache configs}
  s.email = %q{john@coswellproductions.com}

  s.date = Date.today.to_s
  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'

  s.homepage = %q{http://johnbintz.com/}
  s.rdoc_options = ["--charset=UTF-8"]
  s.required_rubygems_version = ">= 1.3.6"

  s.add_development_dependency "bundler", ">= 1.0.0"
  s.add_development_dependency "rspec", "~> 2.0.0"
  s.add_development_dependency "nokogiri"
  s.add_development_dependency "mocha"
  s.add_development_dependency "autotest"
  s.add_development_dependency "reek"

  s.add_dependency 'rainbow'
end
