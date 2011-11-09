require 'spec_helper'

describe Twilio::Participant do

  def resource_uri(account_sid=nil, connect=nil)
    account_sid ||= Twilio::ACCOUNT_SID
    "https://#{connect ? account_sid : Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{account_sid}" +
    "/Conferences/CFbbe46ff1274e283f7e3ac1df0072ab39/Participants/CA386025c9bf5d6052a1d1ea42b4d16662.json"
  end

  let(:participant) do
    Twilio::Participant.new JSON.parse(canned_response('show_participant').read)
  end

  before { Twilio::Config.setup :account_sid => 'AC5ef872f6da5a21de157d80997a64bd33', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def stub_api_call(meth, response_file)
    stub_request(meth, resource_uri).
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '#destroy' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        participant = Twilio::Participant.new JSON.parse(canned_response('show_connect_participant').read)
        stub_request(:delete, resource_uri('AC0000000000000000000000000000', true))
        participant.destroy
        a_request(:delete, resource_uri('AC0000000000000000000000000000', true))
      end
    end

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
        lambda { participant.kick! }.should raise_error(RuntimeError, 'Participant has already been destroyed')
      end
    end
  end

  describe '#kick!' do
    it 'is an alias of destroy' do
      participant.method(:kick!).should === participant.method(:destroy)
    end
  end

  describe '#update_attributes=' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid for basic auth' do
        participant = Twilio::Participant.new JSON.parse(canned_response('show_connect_participant').read)

        stub_request(:post, resource_uri('AC0000000000000000000000000000', true)).
          with(:body => 'Muted=false').
          to_return :body => canned_response('connect_call_created'), :status => 200

        participant.update_attributes :muted => false

        a_request(:post, resource_uri('AC0000000000000000000000000000', true)).
          with(:body => 'Muted=false').
          should have_been_made

      end
    end
  end

  describe '#muted=' do
    it 'makes an api call with the new value' do
      stub_request(:post, resource_uri).to_return :status => 201, :body => canned_response('muted_participant')
      participant.muted = true
      a_request(:post, resource_uri).with(:body => 'Muted=true').should have_been_made
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
        lambda { participant.mute! }.should raise_error(RuntimeError, 'Participant has already been destroyed')
      end
    end
  end
end
