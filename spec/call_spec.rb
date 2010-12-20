require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twilio::Call do

  let(:resource_uri)   { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/AC000000000000/Calls" }
  let(:minimum_params) { 'To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback' }
  let(:call)           { Twilio::Call.create(:to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback') }

  def stub_api_call
    stub_request(:post, resource_uri + '.json').with(:body => minimum_params).
      to_return :body => canned_response('call_created'), :status => 201
  end

  def new_call_should_have_been_made
    a_request(:post, resource_uri + '.json').with(:body => minimum_params).should have_been_made
  end

  def canned_response(resp)
    File.new File.join(File.expand_path(File.dirname __FILE__), 'support', 'responses', "#{resp}.json")
  end

  describe '.find' do
    context 'for a valid call sid' do
      before do
        Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
        stub_request(:get, resource_uri + '/CAa346467ca321c71dbd5e12f627deb854' + '.json').
          to_return :body => canned_response('call_created'), :status => 200
      end

      it 'finds a call with the given call sid' do
        call = Twilio::Call.find 'CAa346467ca321c71dbd5e12f627deb854'
        call.should be_a Twilio::Call
        call.sid.should == 'CAa346467ca321c71dbd5e12f627deb854'
      end
    end

    context 'for a string that does not correspond to a real call' do
      before do
        Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        call = Twilio::Call.find 'phony'
        call.should be_nil
      end
    end
  end

  describe '.create' do
    before do 
      Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
      stub_api_call
    end

    describe "processing attributes" do
      let :call do
        Twilio::Call.create :to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback',
          :send_digits => '1234#00', :if_machine => 'Continue'
      end

      before do
        stub_request(:post, resource_uri + '.json').
          with(:body => "To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback&SendDigits=1234%252300&IfMachine=Continue").
          to_return(:status => 200, :body => canned_response('call_created'))
      end

      it 'escapes send digits because pound, i.e. "#" has special meaning in a url' do
        call
        a_request(:post, resource_uri + '.json').
          with(:body => "To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback&SendDigits=1234%252300&IfMachine=Continue").
          should have_been_made
      end

      it 'capitalises the value of "IfMachine" parameter' do
        call
        a_request(:post, resource_uri + '.json').
          with(:body => "To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback&SendDigits=1234%252300&IfMachine=Continue").
          should have_been_made
      end
    end

    context 'when authentication credentials are not configured' do
      it 'raises Twilio::ConfigurationError' do
        Twilio.send :remove_const, :ACCOUNT_SID
        lambda { call }.should raise_error(Twilio::ConfigurationError)
      end
    end
    context 'when authentication credentials are configured' do
      before(:each) do
        Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
      end
      it 'makes the API call to Twilio' do
        call
        new_call_should_have_been_made
      end
      it 'updates its attributes' do
        call
        call.phone_number_sid.should == "PNd6b0e1e84f7b117332aed2fd2e5bbcab"
      end
    end
  end

  describe 'modifying a call' do
    let(:resource) { resource_uri + '/CAa346467ca321c71dbd5e12f627deb854.json' }
    before do
      Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
      stub_api_call
    end

    describe '#url=' do
      it 'updates the callback URL with the API' do
        stub_request(:post, resource).with(:body => 'url=http%3A%2F%2Ffoo.com').to_return :body => canned_response('call_url_modified'), :status => 201
        call
        call.url = 'http://foo.com'
        call[:url].should == 'http://foo.com'
        a_request(:post, resource).with(:body => 'url=http%3A%2F%2Ffoo.com').should have_been_made
      end
    end

    describe "#cancel!" do
      it "updates the call's status as 'cancelled'" do
        stub_request(:post, resource).with(:body => 'Status=cancelled').to_return :body => canned_response('call_cancelled'), :status => 201
        call.cancel!
        call[:status].should == 'cancelled'
        a_request(:post, resource).with(:body => 'Status=cancelled').should have_been_made
      end

    end

    describe "#complete!" do
    it "updates the call's status as 'completed'" do
          stub_request(:post, resource).with(:body => 'Status=completed').to_return :body => canned_response('call_completed'), :status => 201
          call.complete!
          call[:status].should == 'completed'
          a_request(:post, resource).with(:body => 'Status=completed').should have_been_made
        end 
    end
  end
  
  describe ".create" do
    it "instantiates object and makes API call in one step" do
      Twilio::Config.setup do
        account_sid   'AC000000000000'
        auth_token    '79ad98413d911947f0ba369d295ae7a3'
      end
      stub_api_call
      Twilio::Call.create :to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback'
      new_call_should_have_been_made
    end
  end

  describe "#[]" do
    let(:call) { Twilio::Call.new(:if_machine => 'Continue') }
    it 'is a convenience for reading attributes' do
      call[:if_machine].should == 'Continue'
    end

    it 'accepts a string or symbol' do
      call['if_machine'].should == 'Continue'
    end
  end
  
  describe 'behaviour on API error' do
    it 'raises an exception' do
      Twilio::Config.setup do
        account_sid   'AC000000000000'
        auth_token    '79ad98413d911947f0ba369d295ae7a3'
      end
      stub_request(:post, resource_uri + '.json').with(:body => minimum_params).to_return :body => canned_response('api_error'), :status => 404
      lambda { call }.should raise_error Twilio::APIError
    end
  end
end
