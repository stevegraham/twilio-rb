require 'spec_helper'

describe Twilio::Transcription do

  let(:resource_uri) { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{Twilio::ACCOUNT_SID}/Transcriptions" }
  before { Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') } }

  def stub_api_call(response_file, uri_tail='')
    stub_request(:get, resource_uri + uri_tail + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    before { stub_api_call 'list_transcriptions' }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp = Twilio::Transcription.all
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::Transcription' do
      resp = Twilio::Transcription.all
      resp.all? { |r| r.is_a? Twilio::Transcription }.should be_true
    end
    
    JSON.parse(canned_response('list_transcriptions').read)['transcriptions'].each_with_index do |obj,i|
      obj.each do |attr, value| 
        specify { Twilio::Transcription.all[i].send(attr).should == value }
      end
    end
  end

  describe '.find' do
    context 'for a valid transcription' do
      before do
        stub_request(:get, resource_uri + '/TR8c61027b709ffb038236612dc5af8723' + '.json').
          to_return :body => canned_response('transcription'), :status => 200
      end
      let(:transcription) { Twilio::Transcription.find 'TR8c61027b709ffb038236612dc5af8723' }
      
      it 'returns an instance of Twilio::Transcription.all' do
        transcription.should be_a Twilio::Transcription
      end

      JSON.parse(canned_response('transcription').read).each do |k,v|
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
  end
end
