require 'spec_helper'

describe Twilio::Queue do

  before { Twilio::Config.setup :account_sid => 'ACdc5f1e11047ebd6fe7a55f120be3a900', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def resource_uri(account_sid=nil, connect=nil)
    account_sid ||= Twilio::Config.account_sid
    "https://#{connect ? account_sid : Twilio::Config.account_sid}:#{Twilio::Config.auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/Queues"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  let(:params) do
    { :friendly_name => "switchboard", :max_size => 40 }
  end

  let(:queue) { Twilio::Queue.create params }

  describe '.all' do
    before { stub_api_call 'list_queues' }
    let (:resp) { Twilio::Queue.all }

    it 'returns a collection of objects with a length corresponding to the response' do
      resp.length.should == 2
    end

    it 'returns a collection containing instances of Twilio::Queue' do
      resp.all? { |r| r.is_a? Twilio::Queue }.should be_true
    end

    JSON.parse(canned_response('list_queues'))['queues'].each_with_index do |obj,i|
      obj.each do |attr, value|
        specify { resp[i].send(attr).should == value }
      end
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_queues', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Queue.all :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Queue.all :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.count' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_queues'), :status => 200
        Twilio::Queue.count :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    before { stub_api_call 'list_queues' }
    it 'returns the number of resources' do
      Twilio::Queue.count.should == 2
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_queues', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Queue.count :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Queue.count :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.find' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '/QU14fbe51706f6ef1e4756afXXbed88055.json' ).
          to_return :body => canned_response('list_queues'), :status => 200
        Twilio::Queue.find 'QU14fbe51706f6ef1e4756afXXbed88055', :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    context 'for a valid queue' do
      before do
        stub_request(:get, resource_uri + '/QU14fbe51706f6ef1e4756afXXbed88055' + '.json').
          to_return :body => canned_response('queue'), :status => 200
      end

      let(:queue) { Twilio::Queue.find 'QU14fbe51706f6ef1e4756afXXbed88055' }

      it 'returns an instance of Twilio::Queue.all' do
        queue.should be_a Twilio::Queue
      end

      JSON.parse(canned_response('queue')).each do |k,v|
        specify { queue.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real queue' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        queue = Twilio::Queue.find 'phony'
        queue.should be_nil
      end
    end

    context 'on a subaccount' do
      before do
        stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/QU14fbe51706f6ef1e4756afXXbed88055' + '.json').
          to_return :body => canned_response('notification'), :status => 200
      end

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Queue.find 'QU14fbe51706f6ef1e4756afXXbed88055', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/QU14fbe51706f6ef1e4756afXXbed88055' + '.json').
            should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Queue.find 'QU14fbe51706f6ef1e4756afXXbed88055', :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/QU14fbe51706f6ef1e4756afXXbed88055' + '.json').
            should have_been_made
        end
      end
    end
  end
end
