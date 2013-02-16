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

  describe '.auth_token' do
    it 'raises an exception when invoked before set' do
      expect {
        Twilio::Config.auth_token
      }.to raise_error(Twilio::ConfigurationError, \
        "Cannot complete request. Please set auth_token with Twilio::Config.setup first!")
    end
  end

  describe '.account_sid' do
    it 'raises an exception when invoked before set' do
      expect {
        Twilio::Config.account_sid
      }.to raise_error(Twilio::ConfigurationError, \
        "Cannot complete request. Please set account_sid with Twilio::Config.setup first!")
    end
  end
end
