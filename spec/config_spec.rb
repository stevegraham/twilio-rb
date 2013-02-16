require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twilio::Config do
  describe '.setup' do
    it 'assigns the options hash values to constants in the Twilio namespace that correspond to the key values' do
      Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3'
      Twilio::Config.account_sid.should == 'AC000000000000'
      Twilio::Config.auth_token.should == '79ad98413d911947f0ba369d295ae7a3'
    end

    it 'allows changing the config after initial setup' do
      Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3'
      Twilio::Config.setup :account_sid => 'BC000000000000', :auth_token => '19ad98413d911947f0ba369d295ae7a3'
      Twilio::Config.account_sid.should == 'BC000000000000'
      Twilio::Config.auth_token.should == '19ad98413d911947f0ba369d295ae7a3'
    end
  end
end
