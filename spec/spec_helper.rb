require './lib/twilio'
%w<webmock webmock/rspec>.each { |lib| require lib }

Spec::Runner.configure do |config|
  config.after(:all) do
    [:ACCOUNT_SID, :AUTH_TOKEN].each { |c| Twilio.instance_eval { remove_const c if const_defined? c } }
  end
  config.include WebMock
end