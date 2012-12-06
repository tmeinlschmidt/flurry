# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'flurry/version'

Gem::Specification.new do |gem|
  gem.name          = "flurry"
  gem.version       = Flurry::VERSION
  gem.authors       = ["Tom Meinlschmidt"]
  gem.email         = ["tom@meinlschmidt.org"]
  gem.description   = %q{Used to fetch and communcate with Flurry service}
  gem.summary       = %q{Flurre recommendations, AppCircle etc}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  
  gem.add_development_dependency('fakeweb', '~>1.3.0')
  
  gem.add_dependency "json"
end
