Gem::Specification.new do |s|
  s.platform                = Gem::Platform::RUBY
  s.name                    = 'twilio-rb'
  s.version                 = '0.1.1'
  s.summary                 = 'Interact with the Twilio API in a nice Ruby way.'
  s.description             = 'A nice Ruby wrapper for the Twilio REST API'

  s.required_ruby_version   = '>= 1.8.7'

  s.author                  = 'Stevie Graham'
  s.email                   = 'sjtgraham@mac.com'
  s.homepage                = 'http://github.com/stevegraham/twilio-rb'
  
  s.add_dependency          'activesupport', '>= 3.0.0'
  s.add_dependency          'yajl-ruby',     '>= 0.7.7'
  s.add_dependency          'httparty',      '>= 0.6.1'
  s.add_dependency          'webmock',       '>= 1.3.5'
  

  s.files                   = Dir['README.textile', 'lib/**/*']
  s.require_path            = 'lib'

  s.has_rdoc                = false
end