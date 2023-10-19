# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'que_0_14_3/version'

Gem::Specification.new do |spec|
  spec.name          = 'que_0_14_3'
  spec.version       = Que_0_14_3::Version
  spec.authors       = ["Chris Hanks"]
  spec.email         = ['christopher.m.hanks@gmail.com']
  spec.description   = %q{A job queue that uses PostgreSQL's advisory locks for speed and reliability.}
  spec.summary       = %q{A PostgreSQL-based Job Queue}
  spec.homepage      = 'https://github.com/chanks/que'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ['que_0_14_3']
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
end
