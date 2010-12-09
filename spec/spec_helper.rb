require './lib/twilio'
%w<webmock rspec/expectations webmock/rspec>.each { |lib| require lib }

RSpec.configure do |config|
  config.after(:each) do
    [:ACCOUNT_SID, :AUTH_TOKEN].each { |c| Twilio.instance_eval { remove_const c if const_defined? c } }
  end
  config.include WebMock
end
