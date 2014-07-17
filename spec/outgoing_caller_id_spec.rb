require 'spec_helper'

describe Twilio::OutgoingCallerId do

  before { Twilio::Config.setup :account_sid => 'AC228ba7a5fe4238be081ea6f3c44186f3', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }
  let(:params) { { :phone_number => '+19175551234', :friendly_name => 'barry' } }
  let(:post_body) { 'PhoneNumber=%2B19175551234&FriendlyName=barry'}

  def resource_uri(account_sid=nil, connect=nil)
    account_sid ||= Twilio::Config.account_sid
    "https://#{connect ? account_sid : Twilio::Config.account_sid}:#{Twilio::Config.auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/OutgoingCallerIds"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_caller_ids'), :status => 200
        Twilio::OutgoingCallerId.all :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    before { stub_api_call 'list_caller_ids' }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp = Twilio::OutgoingCallerId.all
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::OutgoingCallerId' do
      resp = Twilio::OutgoingCallerId.all
      resp.all? { |r| r.is_a? Twilio::OutgoingCallerId }.should be_true
    end

    JSON.parse(canned_response('list_caller_ids'))['outgoing_caller_ids'].each_with_index do |obj,i|
      obj.each do |attr, value|
        specify { Twilio::OutgoingCallerId.all[i].send(attr).should == value }
      end
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=barry&Page=5&PhoneNumber=%2B19175551234'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_caller_ids'), :status => 200
      Twilio::OutgoingCallerId.all :page => 5, :phone_number => '+19175551234', :friendly_name => 'barry'
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_caller_ids', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::OutgoingCallerId.all :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::OutgoingCallerId.all :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.count' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_caller_ids'), :status => 200
        Twilio::OutgoingCallerId.count :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

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

    context 'on a subaccount' do
      before { stub_api_call 'list_caller_ids', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::OutgoingCallerId.count :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::OutgoingCallerId.count :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.find' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '/PNe905d7e6b410746a0fb08c57e5a186f3.json' ).
          to_return :body => canned_response('list_connect_caller_ids'), :status => 200
        Twilio::OutgoingCallerId.find 'PNe905d7e6b410746a0fb08c57e5a186f3', :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    context 'for a valid caller_id' do
      before do
        stub_request(:get, resource_uri + '/PNe905d7e6b410746a0fb08c57e5a186f3' + '.json').
          to_return :body => canned_response('caller_id'), :status => 200
      end
      let(:caller_id) { Twilio::OutgoingCallerId.find 'PNe905d7e6b410746a0fb08c57e5a186f3' }

      it 'returns an instance of Twilio::OutgoingCallerId.all' do
        caller_id.should be_a Twilio::OutgoingCallerId
      end

      JSON.parse(canned_response('caller_id')).each do |k,v|
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

    context 'on a subaccount' do
      before do
        stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/PNe905d7e6b410746a0fb08c57e5a186f3' + '.json').
          to_return :body => canned_response('caller_id'), :status => 200
      end

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::OutgoingCallerId.find 'PNe905d7e6b410746a0fb08c57e5a186f3', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/PNe905d7e6b410746a0fb08c57e5a186f3' + '.json').
            should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::OutgoingCallerId.find 'PNe905d7e6b410746a0fb08c57e5a186f3', :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/PNe905d7e6b410746a0fb08c57e5a186f3' + '.json').
            should have_been_made
        end
      end
    end
  end

  describe '.create' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          with(:body => post_body).
          to_return :body => canned_response('connect_caller_id'), :status => 200
        Twilio::OutgoingCallerId.create params.merge(:account_sid => 'AC0000000000000000000000000000', :connect => true)
      end
    end
    context 'on the main account' do
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

    context 'on a subaccount' do
      context 'found by passing in a account sid string' do
        before do
          stub_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).to_return :body => canned_response('caller_id')
        end

        let(:caller_id) { Twilio::OutgoingCallerId.create params.merge(:account_sid => 'SUBACCOUNT_SID') }

        it 'creates a new incoming caller_id on the account' do
          caller_id
          a_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).should have_been_made
        end

        it 'returns an instance of Twilio::OutgoingCallerId' do
          caller_id.should be_a Twilio::OutgoingCallerId
        end

        JSON.parse(canned_response('caller_id')).map do |k,v|
          specify { caller_id.send(k).should == v }
        end
      end

      context 'found by passing in an actual instance of Twilio::Account' do
        before do
          stub_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).to_return :body => canned_response('caller_id')
        end

        let(:caller_id) { Twilio::OutgoingCallerId.create params.merge(:account => double(:sid => 'SUBACCOUNT_SID')) }

        it 'creates a new incoming caller_id on the account' do
          caller_id
          a_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).should have_been_made
        end

        it 'returns an instance of Twilio::OutgoingCallerId' do
          caller_id.should be_a Twilio::OutgoingCallerId
        end

        JSON.parse(canned_response('caller_id')).map do |k,v|
          specify { caller_id.send(k).should == v }
        end
      end
    end
  end

  describe '#destroy' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '/PNe905d7e6b410746a0fb08c57e5a186f3.json' ).
          to_return :body => canned_response('connect_caller_id'), :status => 200
        caller_id = Twilio::OutgoingCallerId.find 'PNe905d7e6b410746a0fb08c57e5a186f3', :account_sid => 'AC0000000000000000000000000000', :connect => true
        stub_request(:delete, resource_uri('AC0000000000000000000000000000', true) + '/' + caller_id.sid + '.json' )
        caller_id.destroy
        a_request(:delete, resource_uri('AC0000000000000000000000000000', true) + '/' + caller_id.sid + '.json' ).should have_been_made
      end
    end

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


    context 'using a twilio connect subaccount' do
      it 'uses the account sid for basic auth' do
        stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          with(:body => post_body).
          to_return :body => canned_response('connect_caller_id'), :status => 200
        caller_id = Twilio::OutgoingCallerId.create params.merge :account_sid => 'AC0000000000000000000000000000', :connect => true

        stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '/' + caller_id.sid + '.json' ).
          with(:body => 'FriendlyName=foo').
          to_return :body => canned_response('connect_caller_id'), :status => 200

        caller_id.update_attributes :friendly_name => 'foo'

        a_request(:post, resource_uri('AC0000000000000000000000000000', true) + '/' + caller_id.sid + '.json' ).
          with(:body => 'FriendlyName=foo').
          should have_been_made

      end
    end

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
