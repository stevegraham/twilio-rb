Gem::Specification.new do |s|
  s.platform                  = Gem::Platform::RUBY
  s.name                      = 'twilio-rb'
  s.version                   = '1.0beta'
  s.summary                   = 'Interact with the Twilio API in a nice Ruby way.'
  s.description               = 'A nice Ruby wrapper for the Twilio REST API'

  s.required_ruby_version     = '>= 1.8.7'

  s.author                    = 'Stevie Graham'
  s.email                     = 'sjtgraham@mac.com'
  s.homepage                  = 'http://github.com/stevegraham/twilio-rb'

  s.add_dependency              'activesupport', '>= 3.0.0'
  s.add_dependency              'i18n',          '~> 0.5.0'
  s.add_dependency              'yajl-ruby',     '>= 0.7.7'
  s.add_dependency              'httparty',      '>= 0.6.1'
  s.add_dependency              'builder',       '>= 2.1.2'

  s.add_development_dependency  'webmock',       '>= 1.6.1'
  s.add_development_dependency  'rspec',         '>= 2.2.0'
  s.add_development_dependency  'mocha',         '>= 0.9.10'

  s.files                     = Dir['README.md', 'lib/**/*']
  s.require_path              = 'lib'

  s.has_rdoc                  = false
end
