require 'spec_helper'

describe Twilio::Recording do

  before { Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') } }

  def resource_uri(account_sid=nil)
    account_sid ||= Twilio::ACCOUNT_SID
    "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/Recordings"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    before { stub_api_call 'list_recordings' }
    let (:resp) { Twilio::Recording.all }

    it 'returns a collection of objects with a length corresponding to the response' do
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::Recording' do
      resp.all? { |r| r.is_a? Twilio::Recording }.should be_true
    end

    JSON.parse(canned_response('list_recordings').read)['recordings'].each_with_index do |obj,i|
      obj.each do |attr, value| 
        specify { resp[i].send(attr).should == value }
      end
    end

    it 'accepts options to refine the search' do
      query = '.json?CallSid=CAa346467ca321c71dbd5e12f627deb854&DateCreated<=2010-12-12&DateCreated>=2010-11-12&Page=5'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_recordings'), :status => 200
      Twilio::Recording.all :page => 5, :call_sid => 'CAa346467ca321c71dbd5e12f627deb854', :created_before => Date.parse('2010-12-12'), :created_after => Date.parse('2010-11-12')
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_recordings', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Recording.all :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Recording.all :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.count' do
    before { stub_api_call 'list_recordings' }
    it 'returns the number of resources' do
      Twilio::Recording.count.should == 527
    end

    it 'accepts options to refine the search' do
      query = '.json?CallSid=CAa346467ca321c71dbd5e12f627deb854&DateCreated<=2010-12-12'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_recordings'), :status => 200
      Twilio::Recording.count :call_sid => 'CAa346467ca321c71dbd5e12f627deb854', :created_before => Date.parse('2010-12-12')
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_recordings', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Recording.count :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Recording.count :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.find' do
    context 'for a valid recording' do
      before do
        stub_request(:get, resource_uri + '/RE557ce644e5ab84fa21cc21112e22c485' + '.json').
          to_return :body => canned_response('recording'), :status => 200
      end

      let(:recording) { Twilio::Recording.find 'RE557ce644e5ab84fa21cc21112e22c485' }

      it 'returns an instance of Twilio::Recording.all' do
        recording.should be_a Twilio::Recording
      end
  
      JSON.parse(canned_response('recording').read).each do |k,v|
        specify { recording.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real recording' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        recording = Twilio::Recording.find 'phony'
        recording.should be_nil
      end
    end

    context 'on a subaccount' do
      before do
        stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/RE557ce644e5ab84fa21cc21112e22c485' + '.json').
          to_return :body => canned_response('notification'), :status => 200
      end

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Recording.find 'RE557ce644e5ab84fa21cc21112e22c485', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/RE557ce644e5ab84fa21cc21112e22c485' + '.json').
            should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Recording.find 'RE557ce644e5ab84fa21cc21112e22c485', :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/RE557ce644e5ab84fa21cc21112e22c485' + '.json').
            should have_been_made
        end
      end
    end
  end

  describe '#destroy' do
    before do
      stub_request(:get, resource_uri + '/RE557ce644e5ab84fa21cc21112e22c485' + '.json').
        to_return :body => canned_response('recording'), :status => 200
      stub_request(:delete, resource_uri + '/RE557ce644e5ab84fa21cc21112e22c485' + '.json').
        to_return :status => 204
    end
    
    let(:recording) { Twilio::Recording.find 'RE557ce644e5ab84fa21cc21112e22c485' }

    it 'deletes the resource' do
      recording.destroy
      a_request(:delete, resource_uri + '/RE557ce644e5ab84fa21cc21112e22c485' + '.json').
      should have_been_made  
    end

    it 'freezes itself if successful' do
      recording.destroy
      recording.should be_frozen
    end

    context 'when the participant has already been kicked' do
      it 'raises a RuntimeError' do
        recording.destroy
        lambda { recording.destroy }.should raise_error(RuntimeError, 'Recording has already been destroyed')
      end
    end
  end

  describe '#mp3' do
    before do
      stub_request(:get, resource_uri + '/RE557ce644e5ab84fa21cc21112e22c485' + '.json').
        to_return :body => canned_response('recording'), :status => 200
    end
    
    let(:recording) { Twilio::Recording.find 'RE557ce644e5ab84fa21cc21112e22c485' }

    it 'returns a url to the mp3 file for the recording' do
      recording.mp3.should == 'https://api.twilio.com/2010-04-01/Accounts/AC000000000000/Recordings/RE557ce644e5ab84fa21cc21112e22c485.mp3'
    end
  end
end
