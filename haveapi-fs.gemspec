# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'haveapi/fs/version'

Gem::Specification.new do |spec|
  spec.name          = 'haveapi-fs'
  spec.version       = HaveAPI::Fs::VERSION
  spec.date          = '2016-11-25'
  spec.authors       = ['Jakub Skokan']
  spec.email         = ['jakub.skokan@vpsfree.cz']
  spec.summary       =
  spec.description   = 'Mount any HaveAPI based API as a filesystem based on FUSE'
  spec.homepage      = ''
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry', '~> 0.10.3'

  spec.add_runtime_dependency 'rfusefs', '~> 1.0.3'
  spec.add_runtime_dependency 'haveapi-client', '~> 0.7.0'
  spec.add_runtime_dependency 'md2man', '~> 5.1.1'
  spec.add_runtime_dependency 'highline', '~> 1.7.8'
end
