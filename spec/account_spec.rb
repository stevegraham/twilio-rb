require 'spec_helper'

describe Twilio::Account do
  it_behaves_like 'a collection resource'

  before { Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def resource_uri(account_sid=nil)
    account_sid ||= Twilio::Config.account_sid
    "https://#{Twilio::Config.account_sid}:#{Twilio::Config.auth_token}@api.twilio.com/2010-04-01/Accounts"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  post_body = "FriendlyName=REST%20test"

  let(:params) { { :friendly_name => 'REST test' } }

  let(:account) { Twilio::Account.create params }

  describe "#friendly_name=" do
    let(:account) { Twilio::Account.create params }

    before do
      stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account')
      stub_request(:post, resource_uri + '/' + account.sid + '.json').
        with(:body => URI.encode("FriendlyName=foo")).to_return :body => canned_response('account'), :status => 201
    end

    it "updates the friendly_name property with the API" do
      account.friendly_name = 'foo'
      a_request(:post, resource_uri + '/' + account.sid + '.json').
        with(:body => URI.encode("FriendlyName=foo")).should have_been_made
    end
  end

  describe "#active?" do
    before { stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account') }

    it 'returns true when the account is active' do
      expect(account).to be_active
    end

    it 'returns false when the account is inactive' do
      account.attributes['status'] = 'dead'
      expect(account).not_to be_active
    end
  end

  describe "#suspended?" do
    before { stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account') }
    it 'returns true when the account is suspended' do
      account.attributes['status'] = 'suspended'
      expect(account).to be_suspended
    end
    it 'returns false when the account not suspended' do
      expect(account).not_to be_suspended
    end
  end
  %w<friendly_name status>.each do |meth|
    describe "##{meth}=" do
      before do
        stub_request(:post, resource_uri + '.json').with(:body => post_body).
          to_return :body => canned_response('account')
        request
      end

      let(:request) do
        stub_request(:post, resource_uri + '/' + account.sid + '.json').
          with(:body => "#{meth.camelize}=foo").
          to_return :body => canned_response('account'), :status => 201
      end

      it 'updates the friendly name' do

        account.send "#{meth}=", 'foo'
        a_request(:post, resource_uri + '/' + account.sid + '.json').with(:body => "#{meth.camelize}=foo").should have_been_made
      end
    end
  end

  describe 'associations' do
    describe 'has_many' do
      it 'delegates the method to the associated class with the account sid merged into the options' do
        stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account')
        [:calls, :recordings, :conferences, :incoming_phone_numbers, :notifications, :outgoing_caller_ids, :transcriptions].each do |association|
          klass = Twilio.const_get association.to_s.classify
          expect(klass).to receive(:foo).with account_sid: account.sid
          account.send(association).foo
        end
      end

      context 'where the account is a connect subaccount' do
        it 'delegates the method to the associated class with the account sid merged into the options' do
          account = Twilio::Account.new JSON.parse(canned_response('connect_account'))
          [:calls, :recordings, :conferences, :incoming_phone_numbers, :notifications, :outgoing_caller_ids, :transcriptions].each do |association|
            klass = Twilio.const_get association.to_s.classify
            expect(klass).to receive(:foo).with account_sid: account.sid, :connect => true
            account.send(association).foo
          end
        end
      end
    end
  end
end
