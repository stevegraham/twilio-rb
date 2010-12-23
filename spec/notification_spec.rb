require 'spec_helper'

describe Twilio::Notification do

  let(:resource_uri) { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{Twilio::ACCOUNT_SID}/Notifications" }
  before { Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') } }

  def stub_api_call(response_file, uri_tail='')
    stub_request(:get, resource_uri + uri_tail + '.json').
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

    it 'returns a collection containing objects with attributes corresponding to the response' do
      notifications = JSON.parse(canned_response('list_notifications').read)['notifications']
      resp    = Twilio::Notification.all

      notifications.each_with_index do |obj,i|
        obj.each do |attr, value| 
          resp[i].send(attr).should == value
        end
      end
    end

    it 'accepts options to refine the search' do
      stub_request(:get, resource_uri + '.json?Log=0&MessageDate<=2010-12-12&MessageDate>=2010-11-12').
        to_return :body => canned_response('list_notifications'), :status => 200
      Twilio::Notification.all :log => '0', :created_before => Date.parse('2010-12-12'), :created_after => Date.parse('2010-11-12')
      a_request(:get, resource_uri + '.json?Log=0&MessageDate<=2010-12-12&MessageDate>=2010-11-12').should have_been_made
    end
  end

  describe '.find' do
    context 'for a valid notification' do
      before do
        stub_request(:get, resource_uri + '/NO5a7a84730f529f0a76b3e30c01315d1a' + '.json').
          to_return :body => canned_response('notification'), :status => 200
      end

      it 'returns an instance of Twilio::Notification.all' do
        notification = Twilio::Notification.find 'NO5a7a84730f529f0a76b3e30c01315d1a'
        notification.should be_a Twilio::Notification
      end

      it 'returns an object with attributes that correspond to the API response' do
        response = JSON.parse(canned_response('notification').read)
        notification     = Twilio::Notification.find 'NO5a7a84730f529f0a76b3e30c01315d1a'
        response.each { |k,v| notification.send(k).should == v }
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
