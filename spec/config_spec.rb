require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twilio::Config do
  describe '.setup' do
    it 'is a DSL that translates methods into constants on the Twilio module and assigns the argument as the value' do
      Twilio::Config.setup do
        account_sid   'AC000000000000'
        auth_token    '79ad98413d911947f0ba369d295ae7a3'
      end
      Twilio.const_get('ACCOUNT_SID').should == 'AC000000000000'
      Twilio.const_get('AUTH_TOKEN').should  == '79ad98413d911947f0ba369d295ae7a3'
    end
  end
end