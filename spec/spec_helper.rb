require './lib/twilio-rb'
%w<webmock rspec/expectations webmock/rspec mocha/api json timecop>.
  each { |lib| require lib }

RSpec.configure do |config|
  config.after(:each) do
    Twilio::Config.account_sid = nil
    Twilio::Config.auth_token = nil
    WebMock.reset!
  end
  config.include WebMock::API
  config.mock_with 'mocha'
end

def canned_response(resp)
  File.new(File.join(File.expand_path(File.dirname __FILE__), 'support', 'responses', "#{resp}.json")).read
end
