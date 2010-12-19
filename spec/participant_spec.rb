require 'spec_helper'

describe Twilio::Participant do

  let(:resource_uri) do 
    "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{Twilio::ACCOUNT_SID}" +
    "/Conferences/CFbbe46ff1274e283f7e3ac1df0072ab39/Participants/CA386025c9bf5d6052a1d1ea42b4d16662.json"
  end
  
  let(:participant) do
    Twilio::Participant.new JSON.parse(canned_response('show_participant').read)
  end

  before { Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') } }

  def stub_api_call(meth, response_file)
    stub_request(meth, resource_uri).
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '#kick!' do
    before { stub_request(:delete, resource_uri).to_return :status => 204 }
    it 'sends a HTTP delete request' do
      participant.kick!
      a_request(:delete, resource_uri).should have_been_made
    end
    it 'freezes itself if successful' do
      participant.kick!
      participant.should be_frozen
    end
    context 'when the participant has already been kicked' do
      it 'raises a RuntimeError' do
        participant.freeze
        lambda { participant.kick! }.should raise_error(RuntimeError, 'Participant has already been removed from conference')
      end
    end
  end
  
  describe '#mute!' do
    context 'when the participant is unmuted' do
      before { stub_request(:post, resource_uri).to_return :status => 201, :body => canned_response('muted_participant') }
      it "mutes the participant" do
        participant.mute!
        participant.should be_muted
        a_request(:post, resource_uri).with(:body => 'Muted=true').should have_been_made
      end
    end
    context 'when the participant is muted' do
      before { stub_request(:post, resource_uri).to_return :status => 201, :body => canned_response('show_participant') }

      let(:participant) do
        Twilio::Participant.new JSON.parse(canned_response('muted_participant').read)
      end

      it "unmutes the participant" do
        participant.mute!
        participant.should_not be_muted
        a_request(:post, resource_uri).with(:body => 'Muted=false').should have_been_made
      end
    end
    context 'when the participant has been kicked' do
      it 'raises a RuntimeError' do
        participant.freeze
        lambda { participant.mute! }.should raise_error(RuntimeError, 'Participant has already been removed from conference')
      end
    end
  end
end
