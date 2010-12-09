require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twilio::Call do

  let(:call_resource_uri)   { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/AC000000000000/Calls" }
  let(:minimum_call_params) { 'To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback' }
  let(:call)                { Twilio::Call.new(:to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback') }

  def stub_new_call
    stub_request(:post, call_resource_uri + '.json').with(:body => minimum_call_params).
      to_return :body => canned_response('call_created'), :status => 201
  end

  def new_call_should_have_been_made
    request(:post, call_resource_uri + '.json').with(:body => minimum_call_params).should have_been_made
  end

  def canned_response(resp)
    File.new File.join(File.expand_path(File.dirname __FILE__), 'support', 'responses', "#{resp}.json")
  end

  describe '.find' do
    context 'for a valid call sid' do
      before do
        Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
        stub_request(:get, call_resource_uri + '/CAa346467ca321c71dbd5e12f627deb854' + '.json').
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
        stub_request(:get, call_resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        call = Twilio::Call.find 'phony'
        call.should be_nil
      end
    end
  end

  describe '.new' do
    describe "processing attributes" do
      it "camelizes the attributes because that's how Twilio rolls" do
        attrs = { :to => '+19175551234', :from => '+19175550000', :url => 'http://localhost:3000/hollaback' }
        attrs.each do |k,v|
          call.attributes.should include k.to_s.camelize
          call.attributes.should_not include k
        end
      end

      it 'upcases attributes that correspond to HTTP verbs' do
        attrs = { :fallback_method => :post, :status_callback_method => :get, :method => :put }
        call  = Twilio::Call.new attrs
        attrs.each do |k,v|
          call.attributes[k.to_s.camelize].should == v.to_s.upcase
          call.attributes[k.to_s.camelize].should_not == v
        end
      end

      it 'escapes send digits because pound, i.e. "#" has special meaning in a url' do
        Twilio::Call.new(:send_digits => '1234#00').attributes['SendDigits'].should == '1234%2300'
      end

      it 'capitalises the value of "IfMachine" parameter' do
        Twilio::Call.new(:if_machine => :continue).attributes['IfMachine'].should == 'Continue'
      end
    end
  end

  describe '#save' do
    context 'when authentication credentials are not configured' do
      it 'raises Twilio::ConfigurationError' do
        lambda { call.save }.should raise_error(Twilio::ConfigurationError)
      end
    end
    context 'when authentication credentials are configured' do
      before(:each) do
        Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
        stub_new_call
      end
      it 'makes the API call to Twilio' do
        call.save
        new_call_should_have_been_made
      end
      it 'updates its attributes' do
        call.save
        call.phone_number_sid.should == "PNd6b0e1e84f7b117332aed2fd2e5bbcab"
      end
    end
  end

  describe 'modifying a call' do
    let(:resource) { call_resource_uri + '/CAa346467ca321c71dbd5e12f627deb854.json' }
    before do
      Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') }
      stub_new_call
    end

    describe '#url=' do
      context 'after the call has been requested via the API' do
        it 'updates the callback URL with the API' do
          stub_request(:post, resource).with(:body => 'url=http%3A%2F%2Ffoo.com').to_return :body => canned_response('call_url_modified'), :status => 201
          call.save
          call.url = 'http://foo.com'
          call[:url].should == 'http://foo.com'
          request(:post, resource).with(:body => 'url=http%3A%2F%2Ffoo.com').should have_been_made
        end
      end
      context 'before the call has been requested via the API' do
        it 'updates the callback URL in its internal state' do
          call.url = 'http://foo.com'
          call[:url].should == 'http://foo.com'
          request(:post, resource).with(:body => 'url=http%3A%2F%2Ffoo.com').should_not have_been_made
        end
      end
    end

    describe "#cancel!" do
      context 'after the call has been requested via the API' do
        it "updates the call's status as 'cancelled'" do
          stub_request(:post, resource).with(:body => 'Status=cancelled').to_return :body => canned_response('call_cancelled'), :status => 201
          call.save
          call.cancel!
          call[:status].should == 'cancelled'
          request(:post, resource).with(:body => 'Status=cancelled').should have_been_made
        end
      end
      context 'before the call has been requested via the API' do
        it 'raises an error' do
          lambda { call.cancel! }.should raise_error Twilio::InvalidStateError
        end
      end
    end

    describe "#complete!" do
      context 'after the call has been requested via the API' do
        it "updates the call's status as 'completed'" do
          stub_request(:post, resource).with(:body => 'Status=completed').to_return :body => canned_response('call_completed'), :status => 201
          call.save
          call.complete!
          call[:status].should == 'completed'
          request(:post, resource).with(:body => 'Status=completed').should have_been_made
        end
      end
      context 'before the call has been requested via the API' do
        it 'raises an error' do
          lambda { call.cancel! }.should raise_error Twilio::InvalidStateError
        end
      end
    end
  end
  
  describe ".create" do
    it "instantiates object and makes API call in one step" do
      Twilio::Config.setup do
        account_sid   'AC000000000000'
        auth_token    '79ad98413d911947f0ba369d295ae7a3'
      end
      stub_new_call
      Twilio::Call.create :to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback'
      new_call_should_have_been_made
    end
  end

  describe "#[]" do
    let(:call) { Twilio::Call.new(:if_machine => :continue) }
    it 'is a convenience for reading attributes' do
      call['IfMachine'].should == 'Continue'
    end

    it 'is agnostic as to whether the attributes are accessed using the symbol style, e.g. :if_machine or the Twilio string style, e.g. "IfMachine"' do
      call[:if_machine].should == 'Continue'
    end
  end

  describe "#[]=" do
    let(:call) { Twilio::Call.new(:if_machine => :continue) }
    it 'is a convenience for writing attributes' do
      call['IfMachine'] = 'hangup'
      call['IfMachine'].should == 'hangup'
    end

    it 'is agnostic as to whether the attributes are accessed using the symbol style, e.g. :if_machine or the Twilio string style, e.g. "IfMachine"' do
      call[:if_machine] = 'hangup'
      call['IfMachine'].should == 'hangup'
    end
  end

  describe 'virtual attributes' do
    it 'does not respond to unknown attributes, i.e. will super via method_missing' do
      call = Twilio::Call.new
      call.should_not respond_to :foo
    end
    it 'does respond to known attributes' do
      call = Twilio::Call.new
      call.foo = 'bar'
      call.foo.should == 'bar'
    end
  end
  
  describe 'behaviour on API error' do
    it 'raises an exception' do
      Twilio::Config.setup do
        account_sid   'AC000000000000'
        auth_token    '79ad98413d911947f0ba369d295ae7a3'
      end
      stub_request(:post, call_resource_uri + '.json').with(:body => minimum_call_params).to_return :body => canned_response('api_error'), :status => 404
      lambda { call.save }.should raise_error Twilio::APIError
    end
  end
end
