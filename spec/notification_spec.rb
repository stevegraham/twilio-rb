require 'spec_helper'

describe Twilio::Notification do

  before { Twilio::Config.setup :account_sid => 'ACda6f1e11047ebd6fe7a55f120be3a900', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def resource_uri(account_sid=nil)
    account_sid ||= Twilio::ACCOUNT_SID
    "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/Notifications"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    before { stub_api_call 'list_notifications' }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp = Twilio::Notification.all
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::Notification' do
      resp = Twilio::Notification.all
      resp.all? { |r| r.is_a? Twilio::Notification }.should be_true
    end

    JSON.parse(canned_response('list_notifications').read)['notifications'].each_with_index do |obj,i|
      obj.each do |attr, value|
        specify { Twilio::Notification.all[i].send(attr).should == value }
      end
    end

    it 'accepts options to refine the search' do
      query = '.json?Log=0&MessageDate<=2010-12-12&MessageDate>=2010-11-12&Page=5'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_notifications'), :status => 200
      Twilio::Notification.all :page => 5, :log => '0', :created_before => Date.parse('2010-12-12'), :created_after => Date.parse('2010-11-12')
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_notifications', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Notification.all :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Notification.all :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.count' do
    before { stub_api_call 'list_notifications' }
    it 'returns the number of resources' do
      Twilio::Notification.count.should == 1224
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=example&PhoneNumber=2125550000'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_notifications'), :status => 200
      Twilio::Notification.count :phone_number => '2125550000', :friendly_name => 'example'
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_notifications', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Notification.count :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Notification.count :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.find' do
    context 'on a subaccount' do
      before do
        stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/NO5a7a84730f529f0a76b3e30c01315d1a' + '.json').
          to_return :body => canned_response('notification'), :status => 200
      end

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Notification.find 'NO5a7a84730f529f0a76b3e30c01315d1a', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/NO5a7a84730f529f0a76b3e30c01315d1a' + '.json').
            should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Notification.find 'NO5a7a84730f529f0a76b3e30c01315d1a', :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/NO5a7a84730f529f0a76b3e30c01315d1a' + '.json').
            should have_been_made
        end
      end
    end

    context 'for a valid notification' do
      before do
        stub_request(:get, resource_uri + '/NO5a7a84730f529f0a76b3e30c01315d1a' + '.json').
          to_return :body => canned_response('notification'), :status => 200
      end
      let(:notification) { Twilio::Notification.find 'NO5a7a84730f529f0a76b3e30c01315d1a' }

      it 'returns an instance of Twilio::Notification.all' do
        notification.should be_a Twilio::Notification
      end

      JSON.parse(canned_response('notification').read).each do |k,v|
        specify { notification.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real notification' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        notification = Twilio::Notification.find 'phony'
        notification.should be_nil
      end
    end
  end

  describe '#destroy' do
    before do
      stub_request(:get, resource_uri + '/NO5a7a84730f529f0a76b3e30c01315d1a' + '.json').
        to_return :body => canned_response('notification'), :status => 200
      stub_request(:delete, resource_uri + '/NO5a7a84730f529f0a76b3e30c01315d1a' + '.json').
        to_return :status => 204
    end

    let(:notification) { Twilio::Notification.find 'NO5a7a84730f529f0a76b3e30c01315d1a' }

    it 'deletes the resource' do
      notification.destroy
      a_request(:delete, resource_uri + '/NO5a7a84730f529f0a76b3e30c01315d1a' + '.json').
      should have_been_made
    end

    it 'freezes itself if successful' do
      notification.destroy
      notification.should be_frozen
    end

    context 'when the participant has already been kicked' do
      it 'raises a RuntimeError' do
        notification.destroy
        lambda { notification.destroy }.should raise_error(RuntimeError, 'Notification has already been destroyed')
      end
    end
  end
end
