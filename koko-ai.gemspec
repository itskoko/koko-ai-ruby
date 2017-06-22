require File.expand_path('../lib/koko/tracker/version', __FILE__)

Gem::Specification.new do |spec|
  spec.name = 'koko-ai-ruby'
  spec.version = Koko::Tracker::VERSION
  spec.files = Dir.glob('**/*')
  spec.require_paths = ['lib']
  spec.summary = 'Koko AI Client'
  spec.description = 'The Koko AI ruby client library'
  spec.authors = ['Koko']
  spec.email = 'us@itskoko.com'
  spec.homepage = 'https://github.com/itskoko/koko-ai-ruby'
  spec.license = 'MIT'

  spec.add_dependency 'commander', '~> 4.4'

  spec.add_development_dependency 'rake', '~> 10.3'
  spec.add_development_dependency 'rspec', '~> 2.0'
  spec.add_development_dependency 'tzinfo', '1.2.1'
  spec.add_development_dependency 'timecop', '0.8.1'
  spec.add_development_dependency 'pry', '~> 0.10.4'
  spec.add_development_dependency 'webmock', '~> 3.0.1'
  spec.add_development_dependency 'activesupport', '>= 3.0.0', '<4.0.0'
end
