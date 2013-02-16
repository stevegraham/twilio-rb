require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'active_support/core_ext/hash'

describe Twilio::Call do

  let(:minimum_params) { 'To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback' }
  let(:call)           { Twilio::Call.create(:to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback') }

  before { Twilio::Config.setup :account_sid => 'AC228ba7a5fe4238be081ea6f3c44186f3', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def resource_uri(account_sid=nil, connect=nil)
    account_sid ||= Twilio::Config.account_sid
    "https://#{connect ? account_sid : Twilio::Config.account_sid}:#{Twilio::Config.auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/Calls"
  end

  def stub_api_call
    stub_request(:post, resource_uri + '.json').with(:body => minimum_params).
      to_return :body => canned_response('call_created'), :status => 201
  end

  def new_call_should_have_been_made
    a_request(:post, resource_uri + '.json').with(:body => minimum_params).should have_been_made
  end

  describe '.all' do
    context 'on the master account' do
      before do
        stub_request(:get, resource_uri + '.json').
          to_return :body => canned_response('list_calls'), :status => 200
      end

      let(:resp) { Twilio::Call.all }
      it 'returns a collection of objects with a length corresponding to the response' do
        resp.length.should == 1
      end

      it 'returns a collection containing instances of Twilio::Call' do
        resp.all? { |r| r.is_a? Twilio::Call }.should be_true
      end

      JSON.parse(canned_response('list_calls'))['calls'].each_with_index do |obj,i|
        obj.each do |attr, value|
          specify { resp[i].send(attr).should == value }
        end
      end

      it 'accepts options to refine the search' do
        stub_request(:get, resource_uri + '.json?EndTime>=2010-11-12&Page=5&StartTime<=2010-12-12&Status=dialled').
          to_return :body => canned_response('list_calls'), :status => 200
        Twilio::Call.all :page => 5, :status => 'dialled', :started_before => Date.parse('2010-12-12'), :ended_after => Date.parse('2010-11-12')
        a_request(:get, resource_uri + '.json?EndTime>=2010-11-12&Page=5&StartTime<=2010-12-12&Status=dialled').should have_been_made
      end
    end

    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_calls'), :status => 200
        Twilio::Call.all :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account_sid' do
        before do
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').
            to_return :body => canned_response('list_calls'), :status => 200
        end

        let(:resp) { Twilio::Call.all :account_sid => 'SUBACCOUNT_SID' }
        it 'returns a collection of objects with a length corresponding to the response' do
          resp.length.should == 1
        end

        it 'returns a collection containing instances of Twilio::Call' do
          resp.all? { |r| r.is_a? Twilio::Call }.should be_true
        end

        JSON.parse(canned_response('list_calls'))['calls'].each_with_index do |obj,i|
          obj.each do |attr, value|
            specify { resp[i].send(attr).should == value }
          end
        end

        it 'accepts options to refine the search' do
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + '.json?EndTime>=2010-11-12&Page=5&StartTime<=2010-12-12&Status=dialled').
            to_return :body => canned_response('list_calls'), :status => 200
          Twilio::Call.all :page => 5, :status => 'dialled', :started_before => Date.parse('2010-12-12'),
            :ended_after => Date.parse('2010-11-12'), :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json?EndTime>=2010-11-12&Page=5&StartTime<=2010-12-12&Status=dialled').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        before do
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').
            to_return :body => canned_response('list_calls'), :status => 200
        end

        let(:resp) { Twilio::Call.all :account => mock(:sid => 'SUBACCOUNT_SID') }
        it 'returns a collection of objects with a length corresponding to the response' do
          resp.length.should == 1
        end

        it 'returns a collection containing instances of Twilio::Call' do
          resp.all? { |r| r.is_a? Twilio::Call }.should be_true
        end

        JSON.parse(canned_response('list_calls'))['calls'].each_with_index do |obj,i|
          obj.each do |attr, value|
            specify { resp[i].send(attr).should == value }
          end
        end

        it 'accepts options to refine the search' do
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + '.json?EndTime>=2010-11-12&Page=5&StartTime<=2010-12-12&Status=dialled').
            to_return :body => canned_response('list_calls'), :status => 200
          Twilio::Call.all :page => 5, :status => 'dialled', :started_before => Date.parse('2010-12-12'),
            :ended_after => Date.parse('2010-11-12'), :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json?EndTime>=2010-11-12&Page=5&StartTime<=2010-12-12&Status=dialled').should have_been_made
        end
      end
    end
  end

  describe '.count' do
    context 'on the master account' do
      it 'returns the number of resources' do
        stub_request(:get, resource_uri + '.json').
          to_return :body => canned_response('list_calls'), :status => 200
        Twilio::Call.count.should == 147
      end

      it 'accepts options to refine the search' do
        query = '.json?FriendlyName=example&Status=in-progress'
        stub_request(:get, resource_uri + query).
          to_return :body => canned_response('list_calls'), :status => 200
        Twilio::Call.count :friendly_name => 'example', :status => 'in-progress'
        a_request(:get, resource_uri + query).should have_been_made
      end
    end

    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_calls'), :status => 200
        Twilio::Call.count :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        it 'returns the number of resources' do
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').
            to_return :body => canned_response('list_calls'), :status => 200
          Twilio::Call.count(:account_sid => 'SUBACCOUNT_SID').should == 147
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example&Status=in-progress'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_calls'), :status => 200
          Twilio::Call.count :friendly_name => 'example', :status => 'in-progress', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'returns the number of resources' do
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').
            to_return :body => canned_response('list_calls'), :status => 200
          Twilio::Call.count(:account => mock(:sid =>'SUBACCOUNT_SID')).should == 147
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example&Status=in-progress'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_calls'), :status => 200
          Twilio::Call.count :friendly_name => 'example', :status => 'in-progress',
            :account => mock(:sid =>'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end
    end
  end

  describe '.find' do
    context 'on the master account' do
      context 'for a valid call sid' do
        before do
          stub_request(:get, resource_uri + '/CAa346467ca321c71dbd5e12f627deb854' + '.json').
            to_return :body => canned_response('call_created'), :status => 200
        end

        let(:call) { Twilio::Call.find 'CAa346467ca321c71dbd5e12f627deb854' }

        it 'returns an instance of Twilio::Call' do
          call.should be_a Twilio::Call
        end

        JSON.parse(canned_response('call_created')).except('method').each do |k,v|
          # OOPS! Collides with Object#method, access with obj[:method] syntax
          specify { call.send(k).should == v }
        end
      end

      context 'for a string that does not correspond to a real call' do
        before { stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404 }

        it 'returns nil' do
          call = Twilio::Call.find 'phony'
          call.should be_nil
        end
      end
    end

    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '/CAa346467ca321c71dbd5e12f627deb854' + '.json' ).
          to_return :body => canned_response('connect_call_created'), :status => 200
        Twilio::Call.find 'CAa346467ca321c71dbd5e12f627deb854', :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        context 'for a valid call sid' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/CAa346467ca321c71dbd5e12f627deb854' + '.json').
              to_return :body => canned_response('call_created'), :status => 200
          end

          let(:call) { Twilio::Call.find 'CAa346467ca321c71dbd5e12f627deb854', :account_sid => 'SUBACCOUNT_SID' }

          it 'returns an instance of Twilio::Call' do
            call.should be_a Twilio::Call
          end

          JSON.parse(canned_response('call_created')).except('method').each do |k,v|
            # OOPS! Collides with Object#method, access with obj[:method] syntax
            specify { call.send(k).should == v }
          end
        end

        context 'for a string that does not correspond to a real call' do
          before { stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/phony' + '.json').to_return :status => 404 }

          it 'returns nil' do
            call = Twilio::Call.find 'phony', :account_sid => 'SUBACCOUNT_SID'
            call.should be_nil
          end
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        context 'for a valid call sid' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/CAa346467ca321c71dbd5e12f627deb854' + '.json').
              to_return :body => canned_response('call_created'), :status => 200
          end

          let(:call) do
            Twilio::Call.find 'CAa346467ca321c71dbd5e12f627deb854', :account => mock(:sid => 'SUBACCOUNT_SID')
          end

          it 'returns an instance of Twilio::Call' do
            call.should be_a Twilio::Call
          end

          JSON.parse(canned_response('call_created')).except('method').each do |k,v|
            # OOPS! Collides with Object#method, access with obj[:method] syntax
            specify { call.send(k).should == v }
          end
        end

        context 'for a string that does not correspond to a real call' do
          before { stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/phony' + '.json').to_return :status => 404 }

          it 'returns nil' do
            call = Twilio::Call.find 'phony', :account => mock(:sid => 'SUBACCOUNT_SID')
            call.should be_nil
          end
        end
      end
    end
  end

  describe '.create' do
    before { stub_api_call }

    describe "processing attributes" do
      let :call do
        Twilio::Call.create :to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback',
          :send_digits => '1234#00', :if_machine => 'Continue'
      end

      before do
        stub_request(:post, resource_uri + '.json').
          with(:body => "To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback&SendDigits=1234%252300&IfMachine=Continue").
          to_return(:status => 200, :body => canned_response('call_created'))
      end

      context 'using a twilio connect subaccount' do
        it 'uses the account sid as the username for basic auth' do
          stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
            with(:body => "To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback&SendDigits=1234%252300&IfMachine=Continue").
            to_return :body => canned_response('connect_call_created'), :status => 200
          Twilio::Call.create :to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback',
            :send_digits => '1234#00', :if_machine => 'Continue', :account_sid => 'AC0000000000000000000000000000', :connect => true
        end
      end

      context 'on a subaccount' do
        before do
          stub_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').
            with(:body => "To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback").
            to_return(:status => 200, :body => canned_response('call_created'))
        end
        context 'found by passing in an account_sid' do
          it 'uses the subaccount sid for the request' do
            Twilio::Call.create :to => '+14155551212', :from => '+14158675309',
              :url => 'http://localhost:3000/hollaback', :account_sid => 'SUBACCOUNT_SID'

            a_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').
              should have_been_made
          end
        end

        context 'found by passing in an instance of Twilio::Account' do
          it 'uses the subaccount sid for the request' do
            Twilio::Call.create :to => '+14155551212', :from => '+14158675309',
            :url => 'http://localhost:3000/hollaback', :account => mock(:sid => 'SUBACCOUNT_SID')

            a_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').
              should have_been_made
          end
        end
      end
      JSON.parse(canned_response('call_created')).except('method').each do |k,v|
        # OOPS! Collides with Object#method, access with obj[:method] syntax
        specify { call.send(k).should == v }
      end

      it 'escapes send digits because pound, i.e. "#" has special meaning in a url' do
        call
        a_request(:post, resource_uri + '.json').
          with(:body => "To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback&SendDigits=1234%252300&IfMachine=Continue").
          should have_been_made
      end

      it 'capitalises the value of "IfMachine" parameter' do
        call
        a_request(:post, resource_uri + '.json').
          with(:body => "To=%2B14155551212&From=%2B14158675309&Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback&SendDigits=1234%252300&IfMachine=Continue").
          should have_been_made
      end
    end

    context 'when authentication credentials are not configured' do
      it 'raises Twilio::ConfigurationError when account_sid is not set' do
        Twilio::Config.account_sid = nil
        lambda { call }.should raise_error(Twilio::ConfigurationError)
      end

      it 'raises Twilio::ConfigurationError when auth_token is not set' do
        Twilio::Config.auth_token = nil
        lambda { call }.should raise_error(Twilio::ConfigurationError)
      end
    end

    context 'when authentication credentials are configured' do
      it 'makes the API call to Twilio' do
        call
        new_call_should_have_been_made
      end
      it 'updates its attributes' do
        call
        call.phone_number_sid.should == "PNd6b0e1e84f7b117332aed2fd2e5bbcab"
      end
    end
  end

  describe 'modifying a call' do
    let(:resource) { resource_uri + '/CAa346467ca321c71dbd5e12f627deb854.json' }
    before { stub_api_call }

    describe '#url=' do
      it 'updates the callback URL with the API' do
        stub_request(:post, resource).with(:body => 'Url=http%3A%2F%2Ffoo.com').to_return :body => canned_response('call_url_modified'), :status => 201
        call.url = 'http://foo.com'
        a_request(:post, resource).with(:body => 'Url=http%3A%2F%2Ffoo.com').should have_been_made
      end
    end

    describe "#cancel!" do
      it "updates the call's status as 'cancelled'" do
        stub_request(:post, resource).with(:body => 'Status=cancelled').to_return :body => canned_response('call_cancelled'), :status => 201
        call.cancel!
        call[:status].should == 'cancelled'
        a_request(:post, resource).with(:body => 'Status=cancelled').should have_been_made
      end

    end

    describe "#complete!" do
    it "updates the call's status as 'completed'" do
          stub_request(:post, resource).with(:body => 'Status=completed').to_return :body => canned_response('call_completed'), :status => 201
          call.complete!
          call[:status].should == 'completed'
          a_request(:post, resource).with(:body => 'Status=completed').should have_been_made
        end
    end
  end

  describe ".create" do
    it "instantiates object and makes API call in one step" do
      stub_api_call
      Twilio::Call.create :to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback'
      new_call_should_have_been_made
    end
  end

  describe "#[]" do
    let(:call) { Twilio::Call.new(:if_machine => 'Continue') }
    it 'is a convenience for reading attributes' do
      call[:if_machine].should == 'Continue'
    end

    it 'accepts a string or symbol' do
      call['if_machine'].should == 'Continue'
    end
  end

  describe 'behaviour on API error' do
    it 'raises an exception' do
      stub_request(:post, resource_uri + '.json').with(:body => minimum_params).to_return :body => canned_response('api_error'), :status => 404
      lambda { call }.should raise_error Twilio::APIError
    end
  end

  describe '#update_attributes' do
    before do
      stub_request(:post, resource_uri + '.json').with(:body => minimum_params).
        to_return :body => canned_response('call_created')
      stub_request(:post, resource_uri + '/' + call.sid + '.json').with(:body => 'Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback').
        to_return :body => canned_response('call_created')
      end
    context 'when the resource has been persisted' do
      it 'updates the API number the new parameters' do
        call.update_attributes :url => 'http://localhost:3000/hollaback'
        a_request(:post, resource_uri + '/' + call.sid + '.json').with(:body => 'Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback').should have_been_made
      end
      context 'using a twilio connect subaccount' do
        it 'uses the account sid for basic auth' do
          stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
            with(:body => minimum_params).
            to_return :body => canned_response('connect_call_created'), :status => 200
          call = Twilio::Call.create :to => '+14155551212', :from => '+14158675309', :url => 'http://localhost:3000/hollaback',
            :account_sid => 'AC0000000000000000000000000000', :connect => true

          stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '/CAa346467ca321c71dbd5e12f627deb854' + '.json' ).
            with(:body => 'Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback').
            to_return :body => canned_response('connect_call_created'), :status => 200

          call.update_attributes :url => 'http://localhost:3000/hollaback'

          a_request(:post, resource_uri('AC0000000000000000000000000000', true) + '/CAa346467ca321c71dbd5e12f627deb854' + '.json' ).
            with(:body => 'Url=http%3A%2F%2Flocalhost%3A3000%2Fhollaback').
            should have_been_made

        end
      end
    end
  end

  %w<url method status>.each do |meth|
    describe "##{meth}=" do

      before do
        stub_request(:post, resource_uri + '.json').with(:body => minimum_params).to_return :body => canned_response('call_created')
        stub_request(:post, resource_uri + '/' + call.sid + '.json').
          with(:body => "#{meth.camelize}=foo").to_return :body => canned_response('call_url_modified'), :status => 201
      end

      it "updates the #{meth} property with the API" do
        call.send "#{meth}=", 'foo'
        a_request(:post, resource_uri + '/' + call.sid + '.json').
          with(:body => "#{meth.camelize}=foo").should have_been_made
      end
    end
  end

  describe 'associations' do
    describe 'has_many' do
      it 'delegates the method to the associated class with the account sid merged into the options' do
        stub_request(:post, resource_uri + '.json').with(:body => minimum_params).
          to_return :body => canned_response('call_created')

        [:recordings, :notifications].each do |association|
          klass = Twilio.const_get association.to_s.classify
          klass.expects(:foo).with  :limit => 5, call_sid: call.sid
          call.send(association).foo :limit => 5
        end
      end

      context 'where the account is a connect subaccount' do
        it 'delegates the method to the associated class with the account sid merged into the options' do
          call = Twilio::Call.new JSON.parse(canned_response('connect_call_created'))
          [:recordings, :notifications].each do |association|
            klass = Twilio.const_get association.to_s.classify
            klass.expects(:foo).with :limit => 5, call_sid: call.sid, :account_sid => call.account_sid, :connect => true
            call.send(association).foo :limit => 5
          end
        end
      end
    end
  end
end
