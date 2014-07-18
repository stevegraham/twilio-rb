require 'spec_helper'

describe Twilio::IncomingPhoneNumber do

  before { Twilio::Config.setup :account_sid => 'ACdc5f1e11047ebd6fe7a55f120be3a900', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def resource_uri(account_sid=nil, connect=nil)
    account_sid ||= Twilio::Config.account_sid
    "https://#{connect ? account_sid : Twilio::Config.account_sid}:#{Twilio::Config.auth_token}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/IncomingPhoneNumbers"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  let(:post_body) do
    "PhoneNumber=%2B19175551234&FriendlyName=barrington&VoiceUrl=http%3A%2F%2Fwww.example.com%2Ftwiml.xml&VoiceMethod=post&VoiceFallbackUrl=http%3A%2F%2Fwww.example.com%2Ftwiml2.xml&" +
    "VoiceFallbackMethod=get&StatusCallback=http%3A%2F%2Fwww.example.com%2Fgoodnite.xml&StatusCallbackMethod=get&SmsUrl=http%3A%2F%2Fwww.example.com%2Ftwiml.xml&SmsMethod=post&" +
    "SmsFallbackUrl=http%3A%2F%2Fwww.example.com%2Ftwiml2.xml&SmsFallbackMethod=get&VoiceCallerIdLookup=false"
  end

  let(:params) do
    { :phone_number => '+19175551234', :friendly_name => 'barrington',
      :voice_url => 'http://www.example.com/twiml.xml', :voice_method => 'post', :voice_fallback_url => 'http://www.example.com/twiml2.xml',
      :voice_fallback_method => 'get', :status_callback => 'http://www.example.com/goodnite.xml', :status_callback_method => 'get',
      :sms_url => 'http://www.example.com/twiml.xml', :sms_method => 'post', :sms_fallback_url => 'http://www.example.com/twiml2.xml',
      :sms_fallback_method => 'get', :voice_caller_id_lookup => false }
  end

  let(:number) { Twilio::IncomingPhoneNumber.create params }

  describe '.count' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_incoming_phone_numbers'), :status => 200
        Twilio::IncomingPhoneNumber.count :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    context 'on the master account' do
      before { stub_api_call 'list_incoming_phone_numbers' }
      it 'returns the number of resources' do
        Twilio::IncomingPhoneNumber.count.should == 6
      end

      it 'accepts options to refine the search' do
        query = '.json?FriendlyName=example&PhoneNumber=2125550000'
        stub_request(:get, resource_uri + query).
          to_return :body => canned_response('list_incoming_phone_numbers'), :status => 200
        Twilio::IncomingPhoneNumber.count :phone_number => '2125550000', :friendly_name => 'example'
        a_request(:get, resource_uri + query).should have_been_made
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        before { stub_api_call 'list_incoming_phone_numbers', 'SUBACCOUNT_SID' }
        it 'returns the number of resources' do
          Twilio::IncomingPhoneNumber.count(:account_sid => 'SUBACCOUNT_SID').should == 6
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example&PhoneNumber=2125550000'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_incoming_phone_numbers'), :status => 200
          Twilio::IncomingPhoneNumber.count :phone_number => '2125550000',
            :friendly_name => 'example', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        before { stub_api_call 'list_incoming_phone_numbers', 'SUBACCOUNT_SID' }
        it 'returns the number of resources' do
          Twilio::IncomingPhoneNumber.count(:account => double(:sid => 'SUBACCOUNT_SID')).should == 6
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example&PhoneNumber=2125550000'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_incoming_phone_numbers'), :status => 200
          Twilio::IncomingPhoneNumber.count :phone_number => '2125550000',
            :friendly_name => 'example', :account => double(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end
    end
  end

  describe '.all' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          to_return :body => canned_response('list_connect_incoming_phone_numbers'), :status => 200
        Twilio::IncomingPhoneNumber.all :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end
    context 'on the master account' do
      before { stub_api_call 'list_incoming_phone_numbers' }
      let(:resp) { resp = Twilio::IncomingPhoneNumber.all }
      it 'returns a collection of objects with a length corresponding to the response' do
        resp.length.should == 1
      end

      it 'returns a collection containing instances of Twilio::AvailablePhoneNumber' do
        resp.all? { |r| r.is_a? Twilio::IncomingPhoneNumber }.should be true
      end

      JSON.parse(canned_response('list_incoming_phone_numbers'))['incoming_phone_numbers'].each_with_index do |obj,i|
        obj.each do |attr, value|
          specify { resp[i].send(attr).should == value }
        end
      end

      it 'accepts options to refine the search' do
        query = '.json?FriendlyName=example&Page=5&PhoneNumber=2125550000'
        stub_request(:get, resource_uri + query).
          to_return :body => canned_response('list_incoming_phone_numbers'), :status => 200
        Twilio::IncomingPhoneNumber.all :page => 5, :phone_number => '2125550000', :friendly_name => 'example'
        a_request(:get, resource_uri + query).should have_been_made
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        before { stub_api_call 'list_incoming_phone_numbers', 'SUBACCOUNT_SID' }
        let(:resp) { resp = Twilio::IncomingPhoneNumber.all :account_sid => 'SUBACCOUNT_SID' }
        it 'returns a collection of objects with a length corresponding to the response' do
          resp.length.should == 1
        end

        it 'returns a collection containing instances of Twilio::AvailablePhoneNumber' do
          resp.all? { |r| r.is_a? Twilio::IncomingPhoneNumber }.should be true
        end

        JSON.parse(canned_response('list_incoming_phone_numbers'))['incoming_phone_numbers'].each_with_index do |obj,i|
          obj.each do |attr, value|
            specify { resp[i].send(attr).should == value }
          end
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example&Page=5&PhoneNumber=2125550000'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_incoming_phone_numbers'), :status => 200
          Twilio::IncomingPhoneNumber.all :page => 5, :phone_number => '2125550000',
            :friendly_name => 'example', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        context 'found by passing in an account sid' do
          before { stub_api_call 'list_incoming_phone_numbers', 'SUBACCOUNT_SID' }
          let(:resp) { resp = Twilio::IncomingPhoneNumber.all :account => double(:sid =>'SUBACCOUNT_SID') }
          it 'returns a collection of objects with a length corresponding to the response' do
            resp.length.should == 1
          end

          it 'returns a collection containing instances of Twilio::AvailablePhoneNumber' do
            resp.all? { |r| r.is_a? Twilio::IncomingPhoneNumber }.should be true
          end

          JSON.parse(canned_response('list_incoming_phone_numbers'))['incoming_phone_numbers'].each_with_index do |obj,i|
            obj.each do |attr, value|
              specify { resp[i].send(attr).should == value }
            end
          end

          it 'accepts options to refine the search' do
            query = '.json?FriendlyName=example&Page=5&PhoneNumber=2125550000'
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
              to_return :body => canned_response('list_incoming_phone_numbers'), :status => 200
            Twilio::IncomingPhoneNumber.all :page => 5, :phone_number => '2125550000',
              :friendly_name => 'example', :account => double(:sid =>'SUBACCOUNT_SID')
            a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
          end
        end
      end
    end
  end

  describe '.find' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '/PN2a0747eba6abf96b7e3c3ff0b4530f6e.json' ).
          to_return :body => canned_response('connect_incoming_phone_number'), :status => 200
        Twilio::IncomingPhoneNumber.find 'PN2a0747eba6abf96b7e3c3ff0b4530f6e', :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end

    context 'on the master account' do
      context 'for a valid number' do
        before do
          stub_request(:get, resource_uri + '/PN2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
            to_return :body => canned_response('incoming_phone_number'), :status => 200
        end

        let(:number) { Twilio::IncomingPhoneNumber.find 'PN2a0747eba6abf96b7e3c3ff0b4530f6e' }

        it 'returns an instance of Twilio::IncomingPhoneNumber' do
          number.should be_a Twilio::IncomingPhoneNumber
        end

        JSON.parse(canned_response('incoming_phone_number')).each do |k,v|
          specify { number.send(k).should == v }
        end
      end

      context 'for a string that does not correspond to a real number' do
        before do
          stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
        end
        it 'returns nil' do
          number = Twilio::IncomingPhoneNumber.find 'phony'
          number.should be_nil
        end
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        context 'for a valid number' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/PN2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
              to_return :body => canned_response('incoming_phone_number'), :status => 200
          end

          let(:number) { Twilio::IncomingPhoneNumber.find 'PN2a0747eba6abf96b7e3c3ff0b4530f6e', :account_sid => 'SUBACCOUNT_SID' }

          it 'returns an instance of Twilio::IncomingPhoneNumber' do
            number.should be_a Twilio::IncomingPhoneNumber
          end

          JSON.parse(canned_response('incoming_phone_number')).each do |k,v|
            specify { number.send(k).should == v }
          end
        end

        context 'for a string that does not correspond to a real number' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/phony' + '.json').to_return :status => 404
          end
          it 'returns nil' do
            number = Twilio::IncomingPhoneNumber.find 'phony', :account_sid => 'SUBACCOUNT_SID'
            number.should be_nil
          end
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        context 'for a valid number' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/PN2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
              to_return :body => canned_response('incoming_phone_number'), :status => 200
          end

          let(:number) do
            Twilio::IncomingPhoneNumber.find 'PN2a0747eba6abf96b7e3c3ff0b4530f6e',
              :account => double(:sid => 'SUBACCOUNT_SID')
          end

          it 'returns an instance of Twilio::IncomingPhoneNumber' do
            number.should be_a Twilio::IncomingPhoneNumber
          end

          JSON.parse(canned_response('incoming_phone_number')).each do |k,v|
            specify { number.send(k).should == v }
          end
        end

        context 'for a string that does not correspond to a real number' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/phony' + '.json').to_return :status => 404
          end
          it 'returns nil' do
            number = Twilio::IncomingPhoneNumber.find 'phony', :account => double(:sid => 'SUBACCOUNT_SID')
            number.should be_nil
          end
        end
      end
    end
  end

  describe '#destroy' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:get, resource_uri('AC0000000000000000000000000000', true) + '/PN2a0747eba6abf96b7e3c3ff0b4530f6e.json' ).
          to_return :body => canned_response('connect_incoming_phone_number'), :status => 200
        number = Twilio::IncomingPhoneNumber.find 'PN2a0747eba6abf96b7e3c3ff0b4530f6e', :account_sid => 'AC0000000000000000000000000000', :connect => true
        stub_request(:delete, resource_uri('AC0000000000000000000000000000', true) + '/' + number.sid + '.json' )
        number.destroy
        a_request(:delete, resource_uri('AC0000000000000000000000000000', true) + '/' + number.sid + '.json' ).should have_been_made
      end
    end

    before do
      stub_request(:get, resource_uri + '/PN2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
        to_return :body => canned_response('incoming_phone_number'), :status => 200
      stub_request(:delete, resource_uri + '/PN2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
        to_return :status => 204
    end

    let(:number) { Twilio::IncomingPhoneNumber.find 'PN2a0747eba6abf96b7e3c3ff0b4530f6e' }

    it 'deletes the resource' do
      number.destroy
      a_request(:delete, resource_uri + '/PN2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
      should have_been_made
    end

    it 'freezes itself if successful' do
      number.destroy
      number.should be_frozen
    end

    context 'when the participant has already been kicked' do
      it 'raises a RuntimeError' do
        number.destroy
        lambda { number.destroy }.should raise_error(RuntimeError, 'IncomingPhoneNumber has already been destroyed')
      end
    end
  end

  describe '.create' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid as the username for basic auth' do
        stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          with(:body => "PhoneNumber=%2B19175551234").
          to_return :body => canned_response('connect_incoming_phone_number'), :status => 200
          Twilio::IncomingPhoneNumber.create :phone_number => '+19175551234', :account_sid => 'AC0000000000000000000000000000', :connect => true
      end
    end
    context 'on the main account' do
      before { stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('incoming_phone_number')}

      it 'creates a new incoming number on the account' do
        number
        a_request(:post, resource_uri + '.json').with(:body => post_body).should have_been_made
      end

      it 'returns an instance of Twilio::IncomingPhoneNumber' do
        number.should be_a Twilio::IncomingPhoneNumber
      end

      JSON.parse(canned_response('incoming_phone_number')).map do |k,v|
        specify { number.send(k).should == v }
      end
    end

    context 'on a subaccount' do
      context 'found by passing in a account sid string' do
        before do
          stub_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).to_return :body => canned_response('incoming_phone_number')
        end

        let(:number) { Twilio::IncomingPhoneNumber.create params.merge(:account_sid => 'SUBACCOUNT_SID') }

        it 'creates a new incoming number on the account' do
          number
          a_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).should have_been_made
        end

        it 'returns an instance of Twilio::IncomingPhoneNumber' do
          number.should be_a Twilio::IncomingPhoneNumber
        end

        JSON.parse(canned_response('incoming_phone_number')).map do |k,v|
          specify { number.send(k).should == v }
        end
      end

      context 'found by passing in an actual instance of Twilio::Account' do
        before do
          stub_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).to_return :body => canned_response('incoming_phone_number')
        end

        let(:number) { Twilio::IncomingPhoneNumber.create params.merge(:account => double(:sid => 'SUBACCOUNT_SID')) }

        it 'creates a new incoming number on the account' do
          number
          a_request(:post, resource_uri('SUBACCOUNT_SID') + '.json').with(:body => post_body).should have_been_made
        end

        it 'returns an instance of Twilio::IncomingPhoneNumber' do
          number.should be_a Twilio::IncomingPhoneNumber
        end

        JSON.parse(canned_response('incoming_phone_number')).map do |k,v|
          specify { number.send(k).should == v }
        end
      end
    end
  end

  describe '#update_attributes' do
    context 'using a twilio connect subaccount' do
      it 'uses the account sid for basic auth' do
        stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '.json' ).
          with(:body => "PhoneNumber=%2B19175551234").
          to_return :body => canned_response('connect_incoming_phone_number'), :status => 200
          number = Twilio::IncomingPhoneNumber.create :phone_number => '+19175551234', :account_sid => 'AC0000000000000000000000000000', :connect => true

        stub_request(:post, resource_uri('AC0000000000000000000000000000', true) + '/' + number.sid + '.json' ).
          with(:body => 'FriendlyName=Sam').
          to_return :body => canned_response('connect_incoming_phone_number'), :status => 200

        number.update_attributes :friendly_name => 'Sam'

        a_request(:post, resource_uri('AC0000000000000000000000000000', true) + '/' + number.sid + '.json' ).
          with(:body => 'FriendlyName=Sam').
          should have_been_made

      end
    end
    before do
        stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('incoming_phone_number')
        stub_request(:post, resource_uri + '/' + number.sid + '.json').with(:body => post_body).
          to_return :body => canned_response('incoming_phone_number')
      end
    context 'when the resource has been destroyed' do
      it 'raises a RuntimeError' do
        stub_request(:delete, resource_uri + '/' + number.sid + '.json').to_return :status => 204, :body => ''
        number.destroy
        lambda { number.update_attributes(params) }.should raise_error RuntimeError, 'IncomingPhoneNumber has already been destroyed'
      end
    end
    context 'when the resource has been persisted' do
      it 'updates the API number the new parameters' do
        number.update_attributes params
        a_request(:post, resource_uri + '/' + number.sid + '.json').with(:body => post_body).should have_been_made
      end
    end
  end

  %w<friendly_name api_version voice_url voice_method voice_fallback_url voice_fallback_method status_callback status_callback_method sms_url sms_method sms_fallback_url sms_fallback_method voice_caller_id_lookup>.each do |meth|
    describe "##{meth}=" do
      let(:number) { Twilio::IncomingPhoneNumber.create params }

      before do
        stub_request(:post, resource_uri + '.json').with(:body => post_body).to_return :body => canned_response('incoming_phone_number')
        stub_request(:post, resource_uri + '/' + number.sid + '.json').
          with(:body => URI.encode("#{meth.camelize}=foo")).to_return :body => canned_response('incoming_phone_number'), :status => 201
      end

      it "updates the #{meth} property with the API" do
        number.send "#{meth}=", 'foo'
        a_request(:post, resource_uri + '/' + number.sid + '.json').
          with(:body => URI.encode("#{meth.camelize}=foo")).should have_been_made
      end
    end
  end
end
