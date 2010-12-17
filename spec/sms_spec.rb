require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twilio::SMS do

  let(:sms_resource_uri)   { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/AC000000000000/SMS/Messages" }
  let(:minimum_sms_params) { 'To=%2B14158141829&From=%2B14159352345&Body=Jenny%20please%3F!%20I%20love%20you%20%3C3' }
  let(:sms)                { Twilio::SMS.create(:to => '+14158141829', :from => '+14159352345', :body => 'Jenny please?! I love you <3') }

  def stub_new_sms
    stub_request(:post, sms_resource_uri + '.json').with(:body => minimum_sms_params).to_return :body => canned_response('sms_created'), :status => 201
  end

  def new_sms_should_have_been_made
    a_request(:post, sms_resource_uri + '.json').with(:body => minimum_sms_params).should have_been_made
  end

  def canned_response(resp)
    File.new File.join(File.expand_path(File.dirname __FILE__), 'support', 'responses', "#{resp}.json")
  end

  describe '.find' do
    context 'for a valid sms sid' do
      before do
        Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
        stub_request(:get, sms_resource_uri + '/SM90c6fc909d8504d45ecdb3a3d5b3556e.json').
          to_return :body => canned_response('sms_created'), :status => 200
      end

      it 'finds a call with the given call sid' do
        sms = Twilio::SMS.find 'SM90c6fc909d8504d45ecdb3a3d5b3556e'
        sms.should be_a Twilio::SMS
        sms.sid.should == 'SM90c6fc909d8504d45ecdb3a3d5b3556e'
      end
    end

    context 'for a string that does not correspond to a real sms' do
      before do
        Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
        stub_request(:get, sms_resource_uri + '/phony.json').to_return :status => 404
      end
      it 'returns nil' do
        sms = Twilio::SMS.find 'phony'
        sms.should be_nil
      end
    end
  end

  describe '#save' do
    context 'when authentication credentials are not configured' do
      it 'raises Twilio::ConfigurationError' do
        lambda { sms }.should raise_error(Twilio::ConfigurationError)
      end
    end
    context 'when authentication credentials are configured' do
      before(:each) do
        Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
        stub_new_sms
      end
      it 'makes the API sms to Twilio' do
        sms
        new_sms_should_have_been_made
      end
      it 'updates its attributes' do
        sms.direction.should == "outbound-api"
      end
    end
  end

  describe ".create" do
    it "sends the message" do
      Twilio::Config.setup do
        account_sid   'AC000000000000'
        auth_token    '79ad98413d911947f0ba369d295ae7a3'
      end
      stub_new_sms
      Twilio::SMS.create :to => '+14158141829', :from => '+14159352345', :body => 'Jenny please?! I love you <3'
      new_sms_should_have_been_made
    end
  end

  describe "#[]" do
    let(:sms) { Twilio::SMS.new(:to => '+19175550000') }
    it 'is a convenience for accessing attributes' do
      sms['To'].should == '+19175550000'
    end

    it 'is agnostic as to whether the attributes are accessed using the symbol style, e.g. :if_machine or the Twilio string style, e.g. "IfMachine"' do
      sms['To'] = '+19175559999'
      sms[:to].should == '+19175559999'
    end
  end

  describe 'behaviour on API error' do
    it 'raises an exception' do
      Twilio::Config.setup do
        account_sid   'AC000000000000'
        auth_token    '79ad98413d911947f0ba369d295ae7a3'
      end
      stub_request(:post, sms_resource_uri + '.json').with(:body => minimum_sms_params).to_return :body => canned_response('api_error'), :status => 404
      lambda { sms.save }.should raise_error Twilio::APIError
    end
  end
end
