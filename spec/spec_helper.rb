require './lib/twilio-rb'
%w<webmock rspec/expectations webmock/rspec mocha json timecop>.each { |lib| require lib }

RSpec.configure do |config|
  config.after(:each) do
    [:ACCOUNT_SID, :AUTH_TOKEN].each { |c| Twilio.instance_eval { remove_const c if const_defined? c } }
    WebMock.reset!
  end
  config.include WebMock::API
  config.mock_with 'mocha'
end

def canned_response(resp)
  File.read "./spec/support/responses/#{resp}.json"
end
