require File.join(File.dirname(__FILE__), '..', 'lib', 'twilio')
%w<webmock webmock/rspec>.each { |lib| require lib }

Spec::Runner.configure do |config|
  config.include WebMock
end