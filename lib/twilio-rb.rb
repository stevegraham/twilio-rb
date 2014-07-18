%w<rubygems active_support active_support/inflector cgi jwt httparty builder>.each  { |lib| require lib }
%w<resource finder persistable deletable associations association_proxy>.each { |lib| require File.join(File.dirname(__FILE__), 'twilio', "#{lib}.rb") }

module Twilio
  VERSION             = "2.1.1"
  API_ENDPOINT        = 'https://api.twilio.com/2010-04-01'
  APIError            = Class.new StandardError
  ConfigurationError  = Class.new StandardError
  InvalidStateError   = Class.new StandardError
end

Dir[File.join(File.dirname(__FILE__), 'twilio', '*.rb')].each { |lib| require lib }

require File.join(File.dirname(__FILE__), 'railtie.rb') if Object.const_defined?(:Rails) && Rails::VERSION::MAJOR >= 3
