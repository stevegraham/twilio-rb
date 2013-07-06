Gem::Specification.new do |s|
  s.platform                    = Gem::Platform::RUBY
  s.name                        = 'twilio-rb'
  s.version                     = '2.2.2'
  s.summary                     = 'Interact with the Twilio API in a nice Ruby way.'
  s.description                 = 'A nice Ruby wrapper for the Twilio REST API'

  s.required_ruby_version       = '>= 1.8.7'

  s.author                      = 'Stevie Graham'
  s.email                       = 'sjtgraham@mac.com'
  s.homepage                    = 'http://github.com/stevegraham/twilio-rb'

  s.add_dependency                'activesupport', '>= 3.0.0'
  s.add_dependency                'i18n',          '~> 0.5'
  s.add_dependency                'httparty',      '~> 0.10.0'
  s.add_dependency                'crack',         '~> 0.3.2'
  s.add_dependency                'builder',       '>= 3.2.2'
  s.add_dependency                'jwt',           '>= 0.1.3'

  s.add_development_dependency    'webmock',       '>= 1.6.1'
  s.add_development_dependency    'rspec',         '>= 2.2.0'
  s.add_development_dependency    'mocha',         '>= 0.9.10'
  s.add_development_dependency    'timecop',       '>= 0.3.5'
  s.add_development_dependency    'rake',          '~> 10.1.0'

  s.files                       = Dir['README.md', 'lib/**/*']
  s.require_path                = 'lib'
end
