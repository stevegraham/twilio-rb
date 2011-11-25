require 'spec_helper'

describe Twilio::Transcription do

  before { Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def resource_uri(account_sid=nil, connect=nil)
    account_sid ||= Twilio::ACCOUNT_SID
    "https://#{connect ? account_sid : Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/Transcriptions"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_transcriptions'), :status => 200
        Twilio::Transcription.all :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    before { stub_api_call 'list_transcriptions' }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp = Twilio::Transcription.all
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::Transcription' do
      resp = Twilio::Transcription.all
      resp.all? { |r| r.is_a? Twilio::Transcription }.should be_true
    end

    JSON.parse(canned_response('list_transcriptions'))['transcriptions'].each_with_index do |obj,i|
      obj.each do |attr, value|
        specify { Twilio::Transcription.all[i].send(attr).should == value }
      end
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_transcriptions', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Transcription.all :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Transcription.all :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.count' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_transcriptions'), :status => 200
        Twilio::Transcription.count :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    before { stub_api_call 'list_transcriptions' }
    it 'returns the number of resources' do
      Twilio::Transcription.count.should == 150
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_transcriptions', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Transcription.count :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Transcription.count :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.find' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '/TR8c61027b709ffb038236612dc5af8723.json' ).
          to_return :body => canned_response('connect_transcription'), :status => 200
        Twilio::Transcription.find 'TR8c61027b709ffb038236612dc5af8723', :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end
    context 'for a valid transcription' do
      before do
        stub_request(:get, resource_uri + '/TR8c61027b709ffb038236612dc5af8723' + '.json').
          to_return :body => canned_response('transcription'), :status => 200
      end
      let(:transcription) { Twilio::Transcription.find 'TR8c61027b709ffb038236612dc5af8723' }

      it 'returns an instance of Twilio::Transcription.all' do
        transcription.should be_a Twilio::Transcription
      end

      JSON.parse(canned_response('transcription')).each do |k,v|
        specify { transcription.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real transcription' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        transcription = Twilio::Transcription.find 'phony'
        transcription.should be_nil
      end
    end

    context 'on a subaccount' do
      before do
        stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/TR8c61027b709ffb038236612dc5af8723' + '.json').
          to_return :body => canned_response('notification'), :status => 200
      end

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Transcription.find 'TR8c61027b709ffb038236612dc5af8723', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/TR8c61027b709ffb038236612dc5af8723' + '.json').
            should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Transcription.find 'TR8c61027b709ffb038236612dc5af8723', :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/TR8c61027b709ffb038236612dc5af8723' + '.json').
            should have_been_made
        end
      end
    end
  end
end
