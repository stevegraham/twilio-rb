require 'spec_helper'

describe Twilio::Account do

  before { Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def resource_uri(account_sid=nil)
    account_sid ||= Twilio::ACCOUNT_SID
    "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  let(:post_body) { "FriendlyName=REST%20test" }

  let(:params) { { :friendly_name => 'REST test' } }

  let(:account) { Twilio::Account.create params }

  describe '.count' do
    before { stub_api_call 'list_accounts' }
    it 'returns the account count' do
      Twilio::Account.count.should == 6
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=example'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_accounts'), :status => 200
      Twilio::Account.count :friendly_name => 'example'
      a_request(:get, resource_uri + query).should have_been_made
    end
  end

  describe '.all' do
    before { stub_api_call 'list_accounts' }
    let(:resp) { resp = Twilio::Account.all }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::Account' do
      resp.all? { |r| r.is_a? Twilio::Account }.should be_true
    end

    JSON.parse(canned_response('list_accounts').read)['accounts'].each_with_index do |obj,i|
      obj.each do |attr, value|
        specify { resp[i].send(attr).should == value }
      end
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=example&Page=5'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_accounts'), :status => 200
      Twilio::Account.all :page => 5, :friendly_name => 'example'
      a_request(:get, resource_uri + query).should have_been_made
    end
  end

  describe '.find' do
    context 'for a valid account' do
      before do
        stub_request(:get, resource_uri + '/AP2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
          to_return :body => canned_response('account'), :status => 200
      end

      let(:account) { Twilio::Account.find 'AP2a0747eba6abf96b7e3c3ff0b4530f6e' }

      it 'returns an instance of Twilio::Account' do
        account.should be_a Twilio::Account
      end

      JSON.parse(canned_response('account').read).each do |k,v|
        specify { account.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real account' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        account = Twilio::Account.find 'phony'
        account.should be_nil
      end
    end
  end

  describe '.create' do
    before { stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account')}

    it 'creates a new incoming account on the account' do
      account
      a_request(:post, resource_uri + '.json').with(:body => post_body).should have_been_made
    end

    it 'returns an instance of Twilio::Account' do
      account.should be_a Twilio::Account
    end

    JSON.parse(canned_response('account').read).map do |k,v|
      specify { account.send(k).should == v }
    end
  end


  describe '#update_attributes' do
    before do
      stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account')
      stub_request(:post, resource_uri + '/' + account.sid + '.json').with(:body => post_body).
        to_return :body => canned_response('account')
    end
    context 'when the resource has been persisted' do
      it 'updates the API account the new parameters' do
        account.update_attributes params
        a_request(:post, resource_uri + '/' + account.sid + '.json').with(:body => post_body).should have_been_made
      end
    end
  end

  %w<friendly_name>.each do |meth|
    describe "##{meth}=" do
      let(:account) { Twilio::Account.create params }

      before do
        stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account')
        stub_request(:post, resource_uri + '/' + account.sid + '.json').
          with(:body => URI.encode("#{meth.camelize}=foo")).to_return :body => canned_response('account'), :status => 201
      end

      it "updates the #{meth} property with the API" do
        account.send "#{meth}=", 'foo'
        a_request(:post, resource_uri + '/' + account.sid + '.json').
          with(:body => URI.encode("#{meth.camelize}=foo")).should have_been_made
      end
    end
  end

  describe "#active?" do
    before { stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account') }
    it 'returns true when the account is active' do
      account.should be_active
    end
    it 'returns false when the account is inactive' do
      account.attributes['status'] = 'dead'
      account.should_not be_active
    end
  end
  describe "#suspended?" do
    before { stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account') }
    it 'returns true when the account is suspended' do
      account.attributes['status'] = 'suspended'
      account.should be_suspended
    end
    it 'returns false when the account not suspended' do
      account.should_not be_suspended
    end
  end
  %w<friendly_name status>.each do |meth|
    describe "##{meth}=" do
      before { stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('account') }
      it 'updates the friendly name' do
        stub_request(:post, resource_uri + '/' + account.sid + '.json').with(:body => "#{meth.camelize}=foo").to_return :body => canned_response('account'), :status => 201
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
          klass.expects(:foo).with :account_sid => account.sid
          account.send(association).foo
        end
      end
    end
  end
end
