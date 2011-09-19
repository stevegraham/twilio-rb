require 'spec_helper'

describe Twilio::ShortCode do

  before { Twilio::Config.setup :account_sid => 'ACdc5f1e6f7a0441659833ca940b72503d', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def resource_uri(account_sid=nil)
    account_sid ||= Twilio::ACCOUNT_SID
    "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/SMS/ShortCodes"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.count' do
    context 'on the master account' do
      before { stub_api_call 'list_short_codes' }
      it 'returns the short_code count' do
        Twilio::ShortCode.count.should == 10
      end

      it 'accepts options to refine the search' do
        query = '.json?FriendlyName=example'
        stub_request(:get, resource_uri + query).
          to_return :body => canned_response('list_short_codes'), :status => 200
        Twilio::ShortCode.count :friendly_name => 'example'
        a_request(:get, resource_uri + query).should have_been_made
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        before { stub_api_call 'list_short_codes', 'SUBACCOUNT_SID' }
        it 'returns the count of short_codes' do
          Twilio::ShortCode.count(:account_sid => 'SUBACCOUNT_SID').should == 10
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_short_codes'), :status => 200
          Twilio::ShortCode.count :friendly_name => 'example', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        before { stub_api_call 'list_short_codes', 'SUBACCOUNT_SID' }
        it 'returns the short_code of resources' do
          Twilio::ShortCode.count(:account => mock(:sid => 'SUBACCOUNT_SID')).should == 10
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_short_codes'), :status => 200
          Twilio::ShortCode.count :friendly_name => 'example', :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end
    end
  end

  describe '.all' do
    context 'on the master account' do
      before { stub_api_call 'list_short_codes' }
      let(:resp) { resp = Twilio::ShortCode.all }
      it 'returns a collection of objects with a length corresponding to the response' do
        resp.length.should == 1
      end

      it 'returns a collection containing instances of Twilio::ShortCode' do
        resp.all? { |r| r.is_a? Twilio::ShortCode }.should be_true
      end

      JSON.parse(canned_response('list_short_codes').read)['short_codes'].each_with_index do |obj,i|
        obj.each do |attr, value|
          specify { resp[i].send(attr).should == value }
        end
      end

      it 'accepts options to refine the search' do
        query = '.json?FriendlyName=example&Page=5'
        stub_request(:get, resource_uri + query).
          to_return :body => canned_response('list_short_codes'), :status => 200
        Twilio::ShortCode.all :page => 5, :friendly_name => 'example'
        a_request(:get, resource_uri + query).should have_been_made
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        before { stub_api_call 'list_short_codes', 'SUBACCOUNT_SID' }
        let(:resp) { resp = Twilio::ShortCode.all :account_sid => 'SUBACCOUNT_SID' }
        it 'returns a collection of objects with a length corresponding to the response' do
          resp.length.should == 1
        end

        it 'returns a collection containing instances of Twilio::ShortCode' do
          resp.all? { |r| r.is_a? Twilio::ShortCode }.should be_true
        end

        JSON.parse(canned_response('list_short_codes').read)['short_codes'].each_with_index do |obj,i|
          obj.each do |attr, value|
            specify { resp[i].send(attr).should == value }
          end
        end

        it 'accepts options to refine the search' do
          query = '.json?FriendlyName=example&Page=5'
          stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
            to_return :body => canned_response('list_short_codes'), :status => 200
          Twilio::ShortCode.all :page => 5, :friendly_name => 'example', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + query).should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        context 'found by passing in an account sid' do
          before { stub_api_call 'list_short_codes', 'SUBACCOUNT_SID' }
          let(:resp) { resp = Twilio::ShortCode.all :account => mock(:sid =>'SUBACCOUNT_SID') }
          it 'returns a collection of objects with a length corresponding to the response' do
            resp.length.should == 1
          end

          it 'returns a collection containing instances of Twilio::ShortCode' do
            resp.all? { |r| r.is_a? Twilio::ShortCode }.should be_true
          end

          JSON.parse(canned_response('list_short_codes').read)['short_codes'].each_with_index do |obj,i|
            obj.each do |attr, value|
              specify { resp[i].send(attr).should == value }
            end
          end

          it 'accepts options to refine the search' do
            query = '.json?FriendlyName=example&Page=5'
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + query).
              to_return :body => canned_response('list_short_codes'), :status => 200
            Twilio::ShortCode.all :page => 5, :friendly_name => 'example', :account => mock(:sid =>'SUBACCOUNT_SID')
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
          stub_request(:get, resource_uri + '/SC6b20cb705c1e8f00210049b20b70fce2' + '.json').
            to_return :body => canned_response('short_code'), :status => 200
        end

        let(:short_code) { Twilio::ShortCode.find 'SC6b20cb705c1e8f00210049b20b70fce2' }

        it 'returns an instance of Twilio::ShortCode' do
          short_code.should be_a Twilio::ShortCode
        end

        JSON.parse(canned_response('short_code').read).each do |k,v|
          specify { short_code.send(k).should == v }
        end
      end

      context 'for a string that does not correspond to a real short_code' do
        before do
          stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
        end
        it 'returns nil' do
          short_code = Twilio::ShortCode.find 'phony'
          short_code.should be_nil
        end
      end
    end

    context 'on a subaccount' do
      context 'found by passing in an account sid' do
        context 'for a valid short_code' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/SC6b20cb705c1e8f00210049b20b70fce2' + '.json').
              to_return :body => canned_response('short_code'), :status => 200
          end

          let(:short_code) { Twilio::ShortCode.find 'SC6b20cb705c1e8f00210049b20b70fce2', :account_sid => 'SUBACCOUNT_SID' }

          it 'returns an instance of Twilio::ShortCode' do
            short_code.should be_a Twilio::ShortCode
          end

          JSON.parse(canned_response('short_code').read).each do |k,v|
            specify { short_code.send(k).should == v }
          end
        end

        context 'for a string that does not correspond to a real short_code' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/phony' + '.json').to_return :status => 404
          end
          it 'returns nil' do
            short_code = Twilio::ShortCode.find 'phony', :account_sid => 'SUBACCOUNT_SID'
            short_code.should be_nil
          end
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        context 'for a valid short_code' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/SC6b20cb705c1e8f00210049b20b70fce2' + '.json').
              to_return :body => canned_response('short_code'), :status => 200
          end

          let(:short_code) do
            Twilio::ShortCode.find 'SC6b20cb705c1e8f00210049b20b70fce2',
              :account => mock(:sid => 'SUBACCOUNT_SID')
          end

          it 'returns an instance of Twilio::ShortCode' do
            short_code.should be_a Twilio::ShortCode
          end

          JSON.parse(canned_response('short_code').read).each do |k,v|
            specify { short_code.send(k).should == v }
          end
        end

        context 'for a string that does not correspond to a real short_code' do
          before do
            stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/phony' + '.json').to_return :status => 404
          end
          it 'returns nil' do
            short_code = Twilio::ShortCode.find 'phony', :account => mock(:sid => 'SUBACCOUNT_SID')
            short_code.should be_nil
          end
        end
      end
    end
  end

  describe '#update_attributes' do
    let(:short_code) { Twilio::ShortCode.find "SC6b20cb705c1e8f00210049b20b70fce2" }

    before do
      stub_request(:get, resource_uri + '/SC6b20cb705c1e8f00210049b20b70fce2' + '.json').
        to_return :body => canned_response('short_code'), :status => 200
      stub_request(:post, resource_uri + '/' + short_code.sid + '.json').
        with(:body => "Foo=bar").to_return :body => canned_response('short_code'), :status => 201
    end
    context 'when the resource has been persisted' do
      it 'updates the API short_code the new parameters' do
        short_code.update_attributes :foo => 'bar'
        a_request(:post, resource_uri + '/' + short_code.sid + '.json').with(:body => "Foo=bar").should have_been_made
      end
    end
  end

  %w<friendly_name api_version sms_url sms_method sms_fallback_url sms_fallback_method>.each do |meth|
    describe "##{meth}=" do
      let(:short_code) { Twilio::ShortCode.find "SC6b20cb705c1e8f00210049b20b70fce2" }

      before do
        stub_request(:get, resource_uri + '/SC6b20cb705c1e8f00210049b20b70fce2' + '.json').
            to_return :body => canned_response('short_code'), :status => 200
        stub_request(:post, resource_uri + '/' + short_code.sid + '.json').
          with(:body => URI.encode("#{meth.camelize}=foo")).to_return :body => canned_response('short_code'), :status => 201
      end

      it "updates the #{meth} property with the API" do
        short_code.send "#{meth}=", 'foo'
        a_request(:post, resource_uri + '/' + short_code.sid + '.json').
          with(:body => URI.encode("#{meth.camelize}=foo")).should have_been_made
      end
    end
  end
end


