require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def canned_response(resp)
  File.new File.join(File.expand_path(File.dirname __FILE__), 'support', 'responses', "#{resp}.json")
end

describe 'Twilio::Account' do
  let(:resource) { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{Twilio::ACCOUNT_SID}.json" }
  before(:each) do
    Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
    stub_request(:get, resource).to_return :body => canned_response('account'), :status => 200
  end

  describe 'accessing account properties' do
    JSON.parse(File.read File.join File.dirname(__FILE__), '/support/responses/account.json').
      each { |meth, value| specify { Twilio::Account.send(meth).should == value } }
  end
  describe "#active?" do
    it 'returns true when the account is active' do
      Twilio::Account.should be_active
    end
    it 'returns false when the account is inactive' do
      Twilio::Account.status = 'dead'
      Twilio::Account.should_not be_active
    end
  end
  describe "#suspended?" do
    it 'returns true when the account is suspended' do
      Twilio::Account.status = 'suspended'
      Twilio::Account.should be_suspended
    end
    it 'returns false when the account not suspended' do
      Twilio::Account.status = 'active'
      Twilio::Account.should_not be_suspended
    end
  end
  describe '#friendly_name=' do
    it 'updates the friendly name' do
      stub_request(:put, resource).with(:body => 'friendly_name=vanity%20name').to_return :body => canned_response('account'), :status => 201
      Twilio::Account.friendly_name = 'vanity name'
      a_request(:put, resource).with(:body => 'friendly_name=vanity%20name').should have_been_made
    end
  end
  describe '#reload!' do
    it "makes a request to the API and updates the object's attributes" do
      Twilio::Account.reload!
      a_request(:get, resource).should have_been_made
    end
  end
end
