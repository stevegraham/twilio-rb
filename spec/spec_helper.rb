require './lib/twilio-rb'

require 'bundler'
Bundler.require

Dir["./spec/support/**/*.rb"].each { |f| require f }

%w<webmock webmock/rspec json timecop rspec/its>.
  each { |lib| require lib }

RSpec.configure do |config|
  config.after(:each) do
    Twilio::Config.account_sid = nil
    Twilio::Config.auth_token = nil
    WebMock.reset!
  end
  config.include WebMock::API
  config.mock_with :rspec
end

def canned_response(resp)
  File.new(File.join(File.expand_path(File.dirname __FILE__), 'support', 'responses', "#{resp}.json")).read
end
