require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twilio::Sandbox do
  before do
    Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3'
    stub_request(:get, resource).to_return :body => canned_response('sandbox'), :status => 200
  end
  let(:resource) { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{Twilio::ACCOUNT_SID}/Sandbox.json" }

  describe 'accessing sandbox properties' do
    JSON.parse(canned_response('sandbox')).
      each { |meth, value| specify { Twilio::Sandbox.send(meth).should == value } }
  end
  %w<voice_url voice_method sms_url sms_method>.each do |meth|
    describe "##{meth}=" do
      it "updates the #{meth} property with the API" do
        stub_request(:post, resource).with(:body => "#{meth.camelize}=foo").to_return :body => canned_response('sandbox'), :status => 201
        Twilio::Sandbox.send "#{meth}=", 'foo'
        a_request(:post, resource).with(:body => "#{meth.camelize}=foo").should have_been_made
      end
    end
  end

  describe '#reload!' do
    it "makes a request to the API and updates the object's attributes" do
      Twilio::Sandbox.reload!
      a_request(:get, resource).should have_been_made
    end
  end
end
