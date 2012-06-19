# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "artdeco/version"

Gem::Specification.new do |s|
  s.name        = "artdeco"
  s.version     = Artdeco::VERSION
  s.authors     = ["Thomas Sonntag"]
  s.email       = ["git@sonntagsbox.de"]
  s.homepage    = ""
  s.summary     = %q{Decorators for Rails}
  s.description = %q{Decorate models with views in a object oriented way}

  s.rubyforge_project = "artdeco"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  s.add_development_dependency "rake"
  s.add_runtime_dependency "activesupport", '>= 3.2'
end
