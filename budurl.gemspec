# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "budurl/version"

Gem::Specification.new do |s|
  s.name        = "budurl"
  s.version     = Budurl::VERSION
  s.authors     = ["Anuj Das"]
  s.email       = ["anuj.das@mylookout.com"]
  s.homepage    = "https://github.com/lookout/budurl-gem"
  s.summary     = %q{A gem for interfacing with the BudURL.Pro url shortener API}
  s.description = %q{Supported operations include shrinking, expanding, and counting clicks.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'httparty'

  # specify any dependencies here; for example:
  s.add_development_dependency 'ruby-debug'
  s.add_development_dependency 'rspec'
  s.add_development_dependency 'mimic'
end
