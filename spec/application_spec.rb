require 'spec_helper'

describe Twilio::Application do

  before { Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def resource_uri(account_sid=nil)
    account_sid ||= Twilio::ACCOUNT_SID
    "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/Applications"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  let(:post_body) do
    "FriendlyName=REST%20test&VoiceUrl=http%3A%2F%2Fwww.example.com%2Ftwiml.xml&VoiceMethod=post&VoiceFallbackUrl=http%3A%2F%2Fwww.example.com%2Ftwiml2.xml&" +
    "VoiceFallbackMethod=get&StatusCallback=http%3A%2F%2Fwww.example.com%2Fgoodnite.xml&StatusCallbackMethod=get&SmsUrl=http%3A%2F%2Fwww.example.com%2Ftwiml.xml&SmsMethod=post&" +
    "SmsFallbackUrl=http%3A%2F%2Fwww.example.com%2Ftwiml2.xml&SmsFallbackMethod=get"
  end

  let(:params) do
    { :friendly_name => 'REST test',
      :voice_url => 'http://www.example.com/twiml.xml', :voice_method => 'post', :voice_fallback_url => 'http://www.example.com/twiml2.xml',
      :voice_fallback_method => 'get', :status_callback => 'http://www.example.com/goodnite.xml', :status_callback_method => 'get',
      :sms_url => 'http://www.example.com/twiml.xml', :sms_method => 'post', :sms_fallback_url => 'http://www.example.com/twiml2.xml',
      :sms_fallback_method => 'get' }
  end

  let(:application) { Twilio::Application.create params }

  describe '.count' do
    context 'on the master account' do
      before { stub_api_call 'list_applications' }
      it 'returns the application count' do
        Twilio::Application.count.should == 6
      end

      it 'accepts options to refine the search' do
        query = '.json?FriendlyName=example'
        stub_request(:get, resource_uri + query).
          to_return :body => canned_response('list_applications'), :status => 200
        Twilio::Application.count :friendly_name => 'example'
        a_request(:get, resource_uri + query).should have_been_made
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        before { stub_api_call 'list_applications', 'SUBACCOUNT_SID' }
        it 'returns the count of applications' do
          Twilio::Application.count(:account_sid => 'SUBACCOUNT_SID').should == 6
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_applications'), :status => 200
          Twilio::Application.count :friendly_name => 'example', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        before { stub_api_call 'list_applications', 'SUBACCOUNT_SID' }
        it 'returns the application of resources' do
          Twilio::Application.count(:account => mock(:sid => 'SUBACCOUNT_SID')).should == 6
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_applications'), :status => 200
          Twilio::Application.count :friendly_name => 'example', :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end
    end
  end

  describe '.all' do
    context 'on the master account' do
      before { stub_api_call 'list_applications' }
      let(:resp) { resp = Twilio::Application.all }
      it 'returns a collection of objects with a length corresponding to the response' do
        resp.length.should == 1
      end

      it 'returns a collection containing instances of Twilio::Application' do
        resp.all? { |r| r.is_a? Twilio::Application }.should be_true
      end

      JSON.parse(canned_response('list_applications').read)['applications'].each_with_index do |obj,i|
        obj.each do |attr, value|
          specify { resp[i].send(attr).should == value }
        end
      end

      it 'accepts options to refine the search' do
        query = '.json?FriendlyName=example&Page=5'
        stub_request(:get, resource_uri + query).
          to_return :body => canned_response('list_applications'), :status => 200
        Twilio::Application.all :page => 5, :friendly_name => 'example'
        a_request(:get, resource_uri + query).should have_been_made
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        before { stub_api_call 'list_applications', 'SUBACCOUNT_SID' }
        let(:resp) { resp = Twilio::Application.all :account_sid => 'SUBACCOUNT_SID' }
        it 'returns a collection of objects with a length corresponding to the response' do
          resp.length.should == 1
        end

        it 'returns a collection containing instances of Twilio::Application' do
          resp.all? { |r| r.is_a? Twilio::Application }.should be_true
        end

        JSON.parse(canned_response('list_applications').read)['applications'].each_with_index do |obj,i|
          obj.each do |attr, value|
            specify { resp[i].send(attr).should == value }
          end
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example&Page=5'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_applications'), :status => 200
          Twilio::Application.all :page => 5, :friendly_name => 'example', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        context 'found by passing in an account sid' do
          before { stub_api_call 'list_applications', 'SUBACCOUNT_SID' }
          let(:resp) { resp = Twilio::Application.all :account => mock(:sid =>'SUBACCOUNT_SID') }
          it 'returns a collection of objects with a length corresponding to the response' do
            resp.length.should == 1
          end

          it 'returns a collection containing instances of Twilio::Application' do
            resp.all? { |r| r.is_a? Twilio::Application }.should be_true
          end

          JSON.parse(canned_response('list_applications').read)['applications'].each_with_index do |obj,i|
            obj.each do |attr, value|
              specify { resp[i].send(attr).should == value }
            end
          end

          it 'accepts options to refine the search' do
            query = '.json?FriendlyName=example&Page=5'
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
              to_return :body => canned_response('list_applications'), :status => 200
            Twilio::Application.all :page => 5, :friendly_name => 'example', :account => mock(:sid =>'SUBACCOUNT_SID')
            a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
          end
        end
      end
    end
  end

  describe '.find' do
    context 'on the master account' do
      context 'for a valid account' do
        before do
          stub_request(:get, resource_uri + '/AP2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
            to_return :body => canned_response('application'), :status => 200
        end

        let(:application) { Twilio::Application.find 'AP2a0747eba6abf96b7e3c3ff0b4530f6e' }

        it 'returns an instance of Twilio::Application' do
          application.should be_a Twilio::Application
        end

        JSON.parse(canned_response('application').read).each do |k,v|
          specify { application.send(k).should == v }
        end
      end

      context 'for a string that does not correspond to a real application' do
        before do
          stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
        end
        it 'returns nil' do
          application = Twilio::Application.find 'phony'
          application.should be_nil
        end
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        context 'for a valid application' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/AP2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
              to_return :body => canned_response('application'), :status => 200
          end

          let(:application) { Twilio::Application.find 'AP2a0747eba6abf96b7e3c3ff0b4530f6e', :account_sid => 'SUBACCOUNT_SID' }

          it 'returns an instance of Twilio::Application' do
            application.should be_a Twilio::Application
          end

          JSON.parse(canned_response('application').read).each do |k,v|
            specify { application.send(k).should == v }
          end
        end

        context 'for a string that does not correspond to a real application' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/phony' + '.json').to_return :status => 404
          end
          it 'returns nil' do
            application = Twilio::Application.find 'phony', :account_sid => 'SUBACCOUNT_SID'
            application.should be_nil
          end
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        context 'for a valid application' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/AP2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
              to_return :body => canned_response('application'), :status => 200
          end

          let(:application) do
            Twilio::Application.find 'AP2a0747eba6abf96b7e3c3ff0b4530f6e',
              :account => mock(:sid => 'SUBACCOUNT_SID')
          end

          it 'returns an instance of Twilio::Application' do
            application.should be_a Twilio::Application
          end

          JSON.parse(canned_response('application').read).each do |k,v|
            specify { application.send(k).should == v }
          end
        end

        context 'for a string that does not correspond to a real application' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/phony' + '.json').to_return :status => 404
          end
          it 'returns nil' do
            application = Twilio::Application.find 'phony', :account => mock(:sid => 'SUBACCOUNT_SID')
            application.should be_nil
          end
        end
      end
    end
  end

  describe '#destroy' do
    before do
      stub_request(:get, resource_uri + '/AP2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
        to_return :body => canned_response('application'), :status => 200
      stub_request(:delete, resource_uri + '/AP2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
        to_return :status => 204
    end

    let(:application) { Twilio::Application.find 'AP2a0747eba6abf96b7e3c3ff0b4530f6e' }

    it 'deletes the resource' do
      application.destroy
      a_request(:delete, resource_uri + '/AP2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
      should have_been_made
    end

    it 'freezes itself if successful' do
      application.destroy
      application.should be_frozen
    end

    context 'when the resource has already been deleted' do
      it 'raises a RuntimeError' do
        application.destroy
        lambda { application.destroy }.should raise_error(RuntimeError, 'Application has already been destroyed')
      end
    end
  end

  describe '.create' do
    context 'on the main account' do
      before { stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('application')}

      it 'creates a new incoming application on the account' do
        application
        a_request(:post, resource_uri + '.json').with(:body => post_body).should have_been_made
      end

      it 'returns an instance of Twilio::Application' do
        application.should be_a Twilio::Application
      end

      JSON.parse(canned_response('application').read).map do |k,v|
        specify { application.send(k).should == v }
      end
    end

    context 'on a subaccount' do
      context 'found by passing in a account sid string' do
        before do
          stub_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).to_return :body => canned_response('application')
        end

        let(:application) { Twilio::Application.create params.merge(:account_sid => 'SUBACCOUNT_SID') }

        it 'creates a new application on the account' do
          application
          a_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).should have_been_made
        end

        it 'returns an instance of Twilio::Application' do
          application.should be_a Twilio::Application
        end

        JSON.parse(canned_response('application').read).map do |k,v|
          specify { application.send(k).should == v }
        end
      end

      context 'found by passing in an actual instance of Twilio::Account' do
        before do
          stub_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).to_return :body => canned_response('application')
        end

        let(:application) { Twilio::Application.create params.merge(:account => mock(:sid => 'SUBACCOUNT_SID')) }

        it 'creates a new application on the account' do
          application
          a_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).should have_been_made
        end

        it 'returns an instance of Twilio::Application' do
          application.should be_a Twilio::Application
        end

        JSON.parse(canned_response('application').read).map do |k,v|
          specify { application.send(k).should == v }
        end
      end
    end
  end

  describe '#update_attributes' do
    before do
        stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('application')
        stub_request(:post, resource_uri + '/' + application.sid + '.json').with(:body => post_body).
          to_return :body => canned_response('application')
      end
    context 'when the resource has been destroyed' do
      it 'raises a RuntimeError' do
        stub_request(:delete, resource_uri + '/' + application.sid + '.json').to_return :status => 204, :body => ''
        application.destroy
        lambda { application.update_attributes(params) }.should raise_error RuntimeError, 'Application has already been destroyed'
      end
    end
    context 'when the resource has been persisted' do
      it 'updates the API application the new parameters' do
        application.update_attributes params
        a_request(:post, resource_uri + '/' + application.sid + '.json').with(:body => post_body).should have_been_made
      end
    end
  end

  %w<friendly_name api_version voice_url voice_method voice_fallback_url voice_fallback_method status_callback status_callback_method sms_url sms_method sms_fallback_url sms_fallback_method>.each do |meth|
    describe "##{meth}=" do
      let(:application) { Twilio::Application.create params }

      before do
        stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('application')
        stub_request(:post, resource_uri + '/' + application.sid + '.json').
          with(:body => URI.encode("#{meth.camelize}=foo")).to_return :body => canned_response('application'), :status => 201
      end

      it "updates the #{meth} property with the API" do
        application.send "#{meth}=", 'foo'
        a_request(:post, resource_uri + '/' + application.sid + '.json').
          with(:body => URI.encode("#{meth.camelize}=foo")).should have_been_made
      end
    end
  end
end

