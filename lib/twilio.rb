%w<rubygems active_support CGI yajl yajl/json_gem httparty>.each  { |lib| require lib }
require File.join(File.dirname(__FILE__), 'twilio', 'resource.rb')

module Twilio
  API_ENDPOINT        = 'https://api.twilio.com/2010-04-01'
  APIError            = Class.new StandardError
  ConfigurationError  = Class.new StandardError
  InvalidStateError   = Class.new StandardError
  
  class << self
    def const_missing(const_name)
      raise Twilio::ConfigurationError.new "Cannot complete request. Please set #{const_name.to_s.downcase} with Twilio::Config.setup first!"
    end
  end
end

Dir[File.join(File.dirname(__FILE__), 'twilio', '*.rb')].each { |lib| require lib }