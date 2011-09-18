require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twilio::Config do
  describe '.setup' do
    it 'assigns the options hash values to constants in the Twilio namespace that correspond to the key values' do
      Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3'
      Twilio.const_get('ACCOUNT_SID').should == 'AC000000000000'
      Twilio.const_get('AUTH_TOKEN').should  == '79ad98413d911947f0ba369d295ae7a3'
    end
  end
end
