%w<rubygems active_support active_support/inflector cgi yajl yajl/json_gem httparty builder jwt>.each  { |lib| require lib }
%w<resource finder persistable deletable>.each { |lib| require File.join(File.dirname(__FILE__), 'twilio', "#{lib}.rb") }

module Twilio
  API_ENDPOINT        = 'https://api.twilio.com/2010-04-01'
  APIError            = Class.new StandardError
  ConfigurationError  = Class.new StandardError
  InvalidStateError   = Class.new StandardError

  class << self
    def const_missing(const_name)
      if [:ACCOUNT_SID, :AUTH_TOKEN].include? const_name
        raise Twilio::ConfigurationError.new "Cannot complete request. Please set #{const_name.to_s.downcase} with Twilio::Config.setup first!"
      else
        super
      end
    end
  end
end

Dir[File.join(File.dirname(__FILE__), 'twilio', '*.rb')].each { |lib| require lib }

require File.join(File.dirname(__FILE__), 'railtie.rb') if Object.const_defined?(:Rails) && Rails.version =~ /^3/
