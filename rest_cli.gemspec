# -*- encoding: utf-8 -*-

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'rest_cli'
  spec.version       = '0.0.1'
  spec.platform      = Gem::Platform::RUBY
  
  spec.summary       = 'A common interface to multiple HTTP/REST API client libraries.'
  spec.description   = 'A common interface to multiple HTTP/REST API libraries, base on Faraday, MultiJson, and Nokogiri.'

  spec.authors       = ['Howl王']
  spec.email         = ['mimosa@aliyun.com']
  spec.homepage      = 'https://github.com/mimosa/rest_cli'
  spec.licenses      = ['MIT']

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'faraday', '~> 0.11.0'
  spec.add_runtime_dependency 'http-cookie', '~> 1.0', '>= 1.0.3'
  spec.add_runtime_dependency 'multi_json', '~> 1.12', '>= 1.12.1'
  spec.add_runtime_dependency 'nokogiri', '~> 1.7', '>= 1.7.0.1'
  spec.add_runtime_dependency 'typhoeus', '~> 1.1', '>= 1.1.2'
  spec.add_runtime_dependency 'oj', '~> 2.18', '>= 2.18.1'
  spec.add_runtime_dependency 'addressable', '~> 2.5'
end