require 'spec_helper'

describe Twilio::AuthorizedConnectApp do

  before { Twilio::Config.setup :account_sid => 'AC228ba7a5fe4238be081ea6f3c44186f3', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }


  def resource_uri(account_sid=nil, connect=nil)
    account_sid ||= Twilio::Config.account_sid
    "https://#{connect ? account_sid : Twilio::Config.account_sid}:#{Twilio::Config.auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/AuthorizedConnectApps"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_authorized_connect_apps'), :status => 200
        Twilio::AuthorizedConnectApp.all :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    before { stub_api_call 'list_authorized_connect_apps' }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp = Twilio::AuthorizedConnectApp.all
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::AuthorizedConnectApp' do
      resp = Twilio::AuthorizedConnectApp.all
      resp.all? { |r| r.is_a? Twilio::AuthorizedConnectApp }.should be_true
    end

    JSON.parse(canned_response('list_authorized_connect_apps'))['authorized_connect_apps'].each_with_index do |obj,i|
      obj.each do |attr, value|
        specify { Twilio::AuthorizedConnectApp.all[i].send(attr).should == value }
      end
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=barry&Page=5'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_authorized_connect_apps'), :status => 200
      Twilio::AuthorizedConnectApp.all :page => 5, :friendly_name => 'barry'
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_authorized_connect_apps', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::AuthorizedConnectApp.all :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::AuthorizedConnectApp.all :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.count' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_authorized_connect_apps'), :status => 200
        Twilio::AuthorizedConnectApp.count :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    before { stub_api_call 'list_authorized_connect_apps' }
    it 'returns the number of resources' do
      Twilio::AuthorizedConnectApp.count.should == 3
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=example'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_authorized_connect_apps'), :status => 200
      Twilio::AuthorizedConnectApp.count :friendly_name => 'example'
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_authorized_connect_apps', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::AuthorizedConnectApp.count :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::AuthorizedConnectApp.count :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.find' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '/CN47260e643654388faabe8aaa18ea6756.json' ).
          to_return :body => canned_response('list_authorized_connect_apps'), :status => 200
        Twilio::AuthorizedConnectApp.find 'CN47260e643654388faabe8aaa18ea6756', :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    context 'for a valid authorized_connect_app' do
      before do
        stub_request(:get, resource_uri + '/CN47260e643654388faabe8aaa18ea6756' + '.json').
          to_return :body => canned_response('authorized_connect_app'), :status => 200
      end
      let(:authorized_connect_app) { Twilio::AuthorizedConnectApp.find 'CN47260e643654388faabe8aaa18ea6756' }

      it 'returns an instance of Twilio::AuthorizedConnectApp.all' do
        authorized_connect_app.should be_a Twilio::AuthorizedConnectApp
      end

      JSON.parse(canned_response('authorized_connect_app')).each do |k,v|
        specify { authorized_connect_app.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real authorized_connect_app' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        authorized_connect_app = Twilio::AuthorizedConnectApp.find 'phony'
        authorized_connect_app.should be_nil
      end
    end

    context 'on a subaccount' do
      before do
        stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/CN47260e643654388faabe8aaa18ea6756' + '.json').
          to_return :body => canned_response('authorized_connect_app'), :status => 200
      end

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::AuthorizedConnectApp.find 'CN47260e643654388faabe8aaa18ea6756', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/CN47260e643654388faabe8aaa18ea6756' + '.json').
            should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::AuthorizedConnectApp.find 'CN47260e643654388faabe8aaa18ea6756', :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/CN47260e643654388faabe8aaa18ea6756' + '.json').
            should have_been_made
        end
      end
    end
  end
end

