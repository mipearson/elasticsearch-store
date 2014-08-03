# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'elasticsearch/store/version'

Gem::Specification.new do |spec|
  spec.name          = "elasticsearch-store"
  spec.version       = Elasticsearch::Store::VERSION
  spec.authors       = ["Michael Pearson"]
  spec.email         = ["mipearson@gmail.com"]
  spec.summary       = %q{ElasticSearch-backed Ruby on Rails cache.}
  spec.description   = %q{}
  spec.homepage      = "http://github.com/mipearson/elasticsearch-store"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "elasticsearch", ">1.0.0"
  spec.add_dependency "activesupport", ">3.2.0"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", ">=3.0.0"
end
