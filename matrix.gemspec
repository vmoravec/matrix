# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'matrix/version'

Gem::Specification.new do |spec|
  spec.name          = "matrix"
  spec.version       = Matrix::VERSION
  spec.authors       = ["Vladimir Moravec"]
  spec.email         = ["vmoravec@suse.com"]
  spec.summary       = %q{Story runner for SUSE Cloud testsuite}
  spec.description   = %q{Built on rake and mkcloud}
  spec.homepage      = "https://github.com/vmoravec/matrix"
  spec.license       = "GNU GPL2"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "bundler", "~> 1.6"
  spec.add_dependency "rake", "~> 10.0"
  spec.add_dependency "awesome_print"
  spec.add_development_dependency "rspec", "~> 3.2"
end
