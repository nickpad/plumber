# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "plumber/version"

Gem::Specification.new do |s|
  s.name        = "plumber"
  s.version     = Plumber::VERSION
  s.authors     = ["Nick Dainty"]
  s.email       = ["nick@npad.co.uk"]
  s.homepage    = "https://github.com/nickpad/plumber"
  s.summary     = %q{Connect anything to an ActiveRecord model}
  s.description = %q{Plumber is a library for creating and updating ActiveRecord models from external data}

  s.rubyforge_project = "plumber"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "activerecord", ">= 3.0.0"
end
