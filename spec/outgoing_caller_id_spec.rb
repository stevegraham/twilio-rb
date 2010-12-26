require 'spec_helper'

describe Twilio::OutgoingCallerId do

  let(:resource_uri) { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{Twilio::ACCOUNT_SID}/OutgoingCallerIds" }
  before { Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') } }
  let(:params) { { :phone_number => '+19175551234', :friendly_name => 'barry' } }
  let(:post_body) { 'PhoneNumber=%2B19175551234&FriendlyName=barry'}


  def stub_api_call(response_file, uri_tail='')
    stub_request(:get, resource_uri + uri_tail + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    before { stub_api_call 'list_caller_ids' }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp = Twilio::OutgoingCallerId.all
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::OutgoingCallerId' do
      resp = Twilio::OutgoingCallerId.all
      resp.all? { |r| r.is_a? Twilio::OutgoingCallerId }.should be_true
    end

    JSON.parse(canned_response('list_caller_ids').read)['outgoing_caller_ids'].each_with_index do |obj,i|
      obj.each do |attr, value| 
        specify { Twilio::OutgoingCallerId.all[i].send(attr).should == value }
      end
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=barry&Page=5&PhoneNumber=+19175551234'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_caller_ids'), :status => 200
      Twilio::OutgoingCallerId.all :page => 5, :phone_number => '+19175551234', :friendly_name => 'barry'
      a_request(:get, resource_uri + query).should have_been_made
    end
  end

  describe '.count' do
    before { stub_api_call 'list_caller_ids' }
    it 'returns the number of resources' do
      Twilio::OutgoingCallerId.count.should == 1
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=example&PhoneNumber=2125550000'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_caller_ids'), :status => 200
      Twilio::OutgoingCallerId.count :phone_number => '2125550000', :friendly_name => 'example'
      a_request(:get, resource_uri + query).should have_been_made
    end
  end

  describe '.find' do
    context 'for a valid caller_id' do
      before do
        stub_request(:get, resource_uri + '/PNe905d7e6b410746a0fb08c57e5a186f3' + '.json').
          to_return :body => canned_response('caller_id'), :status => 200
      end
      let(:caller_id) { Twilio::OutgoingCallerId.find 'PNe905d7e6b410746a0fb08c57e5a186f3' }

      it 'returns an instance of Twilio::OutgoingCallerId.all' do
        caller_id.should be_a Twilio::OutgoingCallerId
      end

      JSON.parse(canned_response('caller_id').read).each do |k,v|
        specify { caller_id.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real caller_id' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        caller_id = Twilio::OutgoingCallerId.find 'phony'
        caller_id.should be_nil
      end
    end
  end

  describe '.create' do

    before { stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('caller_id')}
    let(:caller_id) { Twilio::OutgoingCallerId.create params }

    it 'creates a new incoming caller_id on the account' do
      caller_id
      a_request(:post, resource_uri + '.json').with(:body => post_body).should have_been_made
    end

    it 'returns an instance of Twilio::OutgoingCallerId' do
      caller_id.should be_a Twilio::OutgoingCallerId
    end

    JSON.parse(canned_response('caller_id')).map do |k,v|
      specify { caller_id.send(k).should == v }   
    end
  end

  describe '#destroy' do
    before do
      stub_request(:get, resource_uri + '/PNe905d7e6b410746a0fb08c57e5a186f3' + '.json').
        to_return :body => canned_response('caller_id'), :status => 200
      stub_request(:delete, resource_uri + '/PNe905d7e6b410746a0fb08c57e5a186f3' + '.json').
        to_return :status => 204
    end

    let(:caller_id) { Twilio::OutgoingCallerId.find 'PNe905d7e6b410746a0fb08c57e5a186f3' }

    it 'deletes the resource' do
      caller_id.destroy
      a_request(:delete, resource_uri + '/PNe905d7e6b410746a0fb08c57e5a186f3' + '.json').
        should have_been_made  
    end

    it 'freezes itself if successful' do
      caller_id.destroy
      caller_id.should be_frozen
    end

    context 'when the participant has already been kicked' do
      it 'raises a RuntimeError' do
        caller_id.destroy
        lambda { caller_id.destroy }.should raise_error(RuntimeError, 'OutgoingCallerId has already been destroyed')
      end
    end
  end

  describe '#update_attributes' do
    let(:caller_id) { Twilio::OutgoingCallerId.create params }

    before do
      stub_request(:post, resource_uri + '.json').with(:body => post_body).
        to_return :body => canned_response('caller_id')
      stub_request(:post, resource_uri + '/' + caller_id.sid + '.json').with(params).
        to_return :body => canned_response('caller_id')
    end
    context 'when the resource has been persisted' do
      it 'updates the API number the new parameters' do
        caller_id.update_attributes :url => 'http://localhost:3000/hollaback'
        a_request(:post, resource_uri + '/' + caller_id.sid + '.json').with(params).should have_been_made
      end
    end
  end

  describe '#friendly_name=' do
    let(:caller_id) { Twilio::OutgoingCallerId.create params }

    before do
      stub_request(:post, resource_uri + '.json').with(:body => post_body).
        to_return :body => canned_response('caller_id')
    end

    it 'updates the friendly_name property with the API' do
      stub_request(:post, resource_uri + '/' + caller_id.sid + '.json').
        with(:body => "FriendlyName=foo").to_return :body => canned_response('caller_id'), :status => 201
      caller_id.friendly_name = 'foo'
      a_request(:post, resource_uri + '/' + caller_id.sid + '.json').with(:body => "FriendlyName=foo").should have_been_made
    end
  end
end
