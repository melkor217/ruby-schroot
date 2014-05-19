# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'schroot/version'

Gem::Specification.new do |spec|
  spec.name          = "schroot"
  spec.version       = Schroot::VERSION
  spec.authors       = ["Daniil Guzanov"]
  spec.email         = ["melkor217@gmail.com"]
  spec.summary       = %q{Schroot bindings.}
  spec.description   = %q{Ruby bindings for schroot.}
  spec.homepage      = "https://github.com/melkor217/ruby-schroot"
  spec.license       = "WTFPL"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
