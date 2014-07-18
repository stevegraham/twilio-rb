require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twilio::SMS do

  let(:minimum_sms_params) { 'To=%2B14158141829&From=%2B14159352345&Body=Jenny%20please%3F!%20I%20love%20you%20%3C3' }
  let(:sms)                { Twilio::SMS.create(:to => '+14158141829', :from => '+14159352345', :body => 'Jenny please?! I love you <3') }

  def resource_uri(account_sid=nil, connect=nil)
    account_sid ||= Twilio::Config.account_sid
    "https://#{connect ? account_sid : Twilio::Config.account_sid}:#{Twilio::Config.auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/SMS/Messages"
  end

  def stub_new_sms
    stub_request(:post, resource_uri + '.json').with(:body => minimum_sms_params).to_return :body => canned_response('sms_created'), :status => 201
  end

  def new_sms_should_have_been_made
    a_request(:post, resource_uri + '.json').with(:body => minimum_sms_params).should have_been_made
  end

  before { Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  describe '.all' do
    before do
      stub_request(:get, resource_uri + '.json').
        to_return :body => canned_response('list_messages'), :status => 200
    end

    let(:resp) { Twilio::SMS.all }

    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_messages'), :status => 200
        Twilio::SMS.all :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    it 'returns a collection of objects with a length corresponding to the response' do
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::SMS' do
      resp.all? { |r| r.is_a? Twilio::SMS }.should be true
    end

    JSON.parse(canned_response('list_messages'))['sms_messages'].each_with_index do |obj,i|
      obj.each do |attr, value|
        specify { resp[i].send(attr).should == value }
      end
    end

    it 'accepts options to refine the search' do
      query = '.json?DateSent>=2010-11-12&Page=5&DateSent<=2010-12-12'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_messages'), :status => 200
      Twilio::SMS.all :page => 5, :created_before => Date.parse('2010-12-12'), :sent_after => Date.parse('2010-11-12')
      a_request(:get, resource_uri + query).should have_been_made
    end
  end

  describe '.count' do

    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_messages'), :status => 200
        Twilio::SMS.count :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    it 'returns the number of resources' do
      stub_request(:get, resource_uri + '.json').
        to_return :body => canned_response('list_messages'), :status => 200
      Twilio::SMS.count.should == 261
    end

    it 'accepts options to refine the search' do
      query = '.json?To=%2B19175551234&From=%2B19175550000'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_messages'), :status => 200
      Twilio::SMS.count :to => '+19175551234', :from => '+19175550000'
      a_request(:get, resource_uri + query).should have_been_made
    end
  end

  describe '.find' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '/SMa346467ca321c71dbd5e12f627deb854' + '.json' ).
          to_return :body => canned_response('connect_sms_created'), :status => 200
        Twilio::SMS.find 'SMa346467ca321c71dbd5e12f627deb854', :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    context 'for a valid sms sid' do
      before do
        stub_request(:get, resource_uri + '/SM90c6fc909d8504d45ecdb3a3d5b3556e.json').
          to_return :body => canned_response('sms_created'), :status => 200
      end

      let(:sms) { Twilio::SMS.find 'SM90c6fc909d8504d45ecdb3a3d5b3556e' }

      JSON.parse(canned_response('sms_created')).each do |k,v|
        specify { sms.send(k).should == v }
      end

      it 'returns an instance of Twilio::SMS' do
        sms.should be_a Twilio::SMS
      end
    end

    context 'for a string that does not correspond to a real sms' do
      before { stub_request(:get, resource_uri + '/phony.json').to_return :status => 404 }

      it 'returns nil' do
        sms = Twilio::SMS.find 'phony'
        sms.should be_nil
      end
    end
  end

  describe '.create' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          with(:body => "To=%2B14155551212&From=%2B14158675309&Body=boo").
          to_return :body => canned_response('connect_sms_created'), :status => 200
        Twilio::SMS.create :to => '+14155551212', :from => '+14158675309', :body => 'boo', :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end
    context 'when authentication credentials are not configured' do
      it 'raises Twilio::ConfigurationError' do
        Twilio::Config.account_sid = nil
        lambda { sms }.should raise_error(Twilio::ConfigurationError)
      end
    end
    context 'when authentication credentials are configured' do
      before(:each) { stub_new_sms }

      it 'makes the API sms to Twilio' do
        sms
        new_sms_should_have_been_made
      end

      JSON.parse(canned_response('sms_created')).each do |k,v|
        specify { sms.send(k).should == v }
      end
    end
  end

  describe "#[]" do
    let(:sms) { Twilio::SMS.new(:to => '+19175550000') }
    it 'is a convenience for accessing attributes' do
      sms[:to].should == '+19175550000'
    end

    it 'accepts a string or symbol' do
      sms['to'] = '+19175559999'
      sms[:to].should == '+19175559999'
    end
  end

  describe 'behaviour on API error' do
    it 'raises an exception' do
      stub_request(:post, resource_uri + '.json').with(:body => minimum_sms_params).to_return :body => canned_response('api_error'), :status => 404
      lambda { sms.save }.should raise_error Twilio::APIError
    end
  end
end
