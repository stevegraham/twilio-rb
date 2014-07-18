require 'spec_helper'

describe Twilio::ConnectApp do

  before { Twilio::Config.setup :account_sid => 'AC228ba7a5fe4238be081ea6f3c44186f3', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }


  def resource_uri(account_sid=nil, connect=nil)
    account_sid ||= Twilio::Config.account_sid
    "https://#{connect ? account_sid : Twilio::Config.account_sid}:#{Twilio::Config.auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/ConnectApps"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    before { stub_api_call 'list_connect_apps' }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp = Twilio::ConnectApp.all
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::ConnectApp' do
      resp = Twilio::ConnectApp.all
      resp.all? { |r| r.is_a? Twilio::ConnectApp }.should be true
    end

    JSON.parse(canned_response('list_connect_apps'))['connect_apps'].each_with_index do |obj,i|
      obj.each do |attr, value|
        specify { Twilio::ConnectApp.all[i].send(attr).should == value }
      end
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=barry&Page=5'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_connect_apps'), :status => 200
      Twilio::ConnectApp.all :page => 5, :friendly_name => 'barry'
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_connect_apps', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::ConnectApp.all :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::ConnectApp.all :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.count' do
    before { stub_api_call 'list_connect_apps' }
    it 'returns the number of resources' do
      Twilio::ConnectApp.count.should == 3
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=example'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_connect_apps'), :status => 200
      Twilio::ConnectApp.count :friendly_name => 'example'
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_connect_apps', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::ConnectApp.count :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::ConnectApp.count :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.find' do
    context 'for a valid connect_app' do
      before do
        stub_request(:get, resource_uri + '/CNb989fdd207b04d16aee578018ef5fd93' + '.json').
          to_return :body => canned_response('connect_app'), :status => 200
      end
      let(:connect_app) { Twilio::ConnectApp.find 'CNb989fdd207b04d16aee578018ef5fd93' }

      it 'returns an instance of Twilio::ConnectApp.all' do
        connect_app.should be_a Twilio::ConnectApp
      end

      JSON.parse(canned_response('connect_app')).each do |k,v|
        specify { connect_app.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real connect_app' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        connect_app = Twilio::ConnectApp.find 'phony'
        connect_app.should be_nil
      end
    end

    context 'on a subaccount' do
      before do
        stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/CNb989fdd207b04d16aee578018ef5fd93' + '.json').
          to_return :body => canned_response('connect_app'), :status => 200
      end

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::ConnectApp.find 'CNb989fdd207b04d16aee578018ef5fd93', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/CNb989fdd207b04d16aee578018ef5fd93' + '.json').
            should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::ConnectApp.find 'CNb989fdd207b04d16aee578018ef5fd93', :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/CNb989fdd207b04d16aee578018ef5fd93' + '.json').
            should have_been_made
        end
      end
    end
  end
  describe '#update_attributes=' do
    it 'updates the API number the new parameters' do
      connect_app = Twilio::ConnectApp.new JSON.parse(canned_response('connect_app'))
      stub_request(:post, resource_uri + '/' + connect_app.sid + '.json').with(:body => 'FriendlyName=foo').
        to_return body: canned_response('connect_app'), status: 200
      connect_app.update_attributes :friendly_name => 'foo'
      a_request(:post, resource_uri + '/' + connect_app.sid + '.json').with(:body => 'FriendlyName=foo').should have_been_made
    end
  end
end


