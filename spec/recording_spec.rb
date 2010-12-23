require 'spec_helper'

describe Twilio::Recording do

  let(:resource_uri) { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{Twilio::ACCOUNT_SID}/Recordings" }
  before { Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') } }

  def stub_api_call(response_file, uri_tail='')
    stub_request(:get, resource_uri + uri_tail + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    before { stub_api_call 'list_recordings' }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp = Twilio::Recording.all
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::Recording' do
      resp = Twilio::Recording.all
      resp.all? { |r| r.is_a? Twilio::Recording }.should be_true
    end

    it 'returns a collection containing objects with attributes corresponding to the response' do
      recordings = JSON.parse(canned_response('list_recordings').read)['recordings']
      resp    = Twilio::Recording.all

      recordings.each_with_index do |obj,i|
        obj.each do |attr, value| 
          resp[i].send(attr).should == value
        end
      end
    end

    it 'accepts options to refine the search' do
      stub_request(:get, resource_uri + '.json?CallSid=CAa346467ca321c71dbd5e12f627deb854&DateCreated<=2010-12-12&DateCreated>=2010-11-12').
        to_return :body => canned_response('list_recordings'), :status => 200
      Twilio::Recording.all :call_sid => 'CAa346467ca321c71dbd5e12f627deb854', :created_before => Date.parse('2010-12-12'), :created_after => Date.parse('2010-11-12')
      a_request(:get, resource_uri + '.json?CallSid=CAa346467ca321c71dbd5e12f627deb854&DateCreated<=2010-12-12&DateCreated>=2010-11-12').should have_been_made
    end
  end

  describe '.find' do
    context 'for a valid recording' do
      before do
        stub_request(:get, resource_uri + '/RE557ce644e5ab84fa21cc21112e22c485' + '.json').
          to_return :body => canned_response('recording'), :status => 200
      end

      it 'returns an instance of Twilio::Recording.all' do
        recording = Twilio::Recording.find 'RE557ce644e5ab84fa21cc21112e22c485'
        recording.should be_a Twilio::Recording
      end

      it 'returns an object with attributes that correspond to the API response' do
        response = JSON.parse(canned_response('recording').read)
        recording     = Twilio::Recording.find 'RE557ce644e5ab84fa21cc21112e22c485'
        response.each { |k,v| recording.send(k).should == v }
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
