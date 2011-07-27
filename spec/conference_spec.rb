require 'spec_helper'

describe Twilio::Conference do

  before { Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') } }

  def resource_uri(account_sid=nil)
    account_sid ||= Twilio::ACCOUNT_SID
    "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{account_sid}/Conferences"
  end

  def stub_api_call(response_file, account_sid=nil)
    stub_request(:get, resource_uri(account_sid) + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    context 'context on the master account' do
      before { stub_api_call 'list_conferences' }
      it 'returns a collection of objects with a length corresponding to the response' do
        resp = Twilio::Conference.all
        resp.length.should == 1
      end

      it 'returns a collection containing instances of Twilio::Conference' do
        resp = Twilio::Conference.all
        resp.all? { |r| r.is_a? Twilio::Conference }.should be_true
      end

      it 'returns a collection containing objects with attributes corresponding to the response' do
        conferences = JSON.parse(canned_response('list_conferences').read)['conferences']
        resp        = Twilio::Conference.all

        conferences.each_with_index do |obj,i|
          obj.each do |attr, value| 
            resp[i].send(attr).should == value
          end
        end
      end

      it 'accepts options to refine the search' do
        query = '.json?FriendlyName=example&Status=in-progress&Page=5&DateCreated>=1970-01-01&DateUpdated<=2038-01-19'
        stub_request(:get, resource_uri + query).to_return :body => canned_response('list_conferences'), :status => 200
        Twilio::Conference.all :page => 5, :friendly_name => 'example', :status => 'in-progress',
          :created_after => Date.parse('1970-01-01'), :updated_before => Date.parse('2038-01-19')
        a_request(:get, resource_uri + query).should have_been_made
      end
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_conferences', 'SUBACCOUNT_SID' }

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Conference.all :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Conference.all :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.count' do
    before { stub_api_call 'list_conferences' }
    it 'returns the number of resources' do
      Twilio::Conference.count.should == 462
    end

    it 'accepts options to refine the search' do
      query = '.json?FriendlyName=example&Status=in-progress'
      stub_request(:get, resource_uri + query).
        to_return :body => canned_response('list_conferences'), :status => 200
      Twilio::Conference.count :friendly_name => 'example', :status => 'in-progress'
      a_request(:get, resource_uri + query).should have_been_made
    end

    context 'on a subaccount' do
      before { stub_api_call 'list_conferences', 'SUBACCOUNT_SID' }
      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Conference.count :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Conference.count :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '.json').should have_been_made
        end
      end
    end
  end

  describe '.find' do
    context 'on a subaccount' do
      before do
        stub_request(:get, resource_uri('SUBACCOUNT_SID') + '/CFbbe46ff1274e283f7e3ac1df0072ab39' + '.json').
          to_return :body => canned_response('conference'), :status => 200
      end

      context 'found by passing in an account_sid' do
        it 'uses the subaccount sid in the request' do
          Twilio::Conference.find 'CFbbe46ff1274e283f7e3ac1df0072ab39', :account_sid => 'SUBACCOUNT_SID'
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/CFbbe46ff1274e283f7e3ac1df0072ab39' + '.json').
          should have_been_made
        end
      end

      context 'found by passing in an instance of Twilio::Account' do
        it 'uses the subaccount sid in the request' do
          Twilio::Conference.find 'CFbbe46ff1274e283f7e3ac1df0072ab39', :account => mock(:sid => 'SUBACCOUNT_SID')
          a_request(:get, resource_uri('SUBACCOUNT_SID') + '/CFbbe46ff1274e283f7e3ac1df0072ab39' + '.json').
          should have_been_made
        end
      end
    end

    context 'for a valid conference' do
      before do
        stub_request(:get, resource_uri + '/CFbbe46ff1274e283f7e3ac1df0072ab39' + '.json').
          to_return :body => canned_response('conference'), :status => 200
      end

      it 'returns an instance of Twilio::Conference' do
        conference = Twilio::Conference.find 'CFbbe46ff1274e283f7e3ac1df0072ab39'
        conference.should be_a Twilio::Conference 
      end

      it 'returns an object with attributes that correspond to the API response' do
        response   = JSON.parse(canned_response('conference').read)
        conference = Twilio::Conference.find 'CFbbe46ff1274e283f7e3ac1df0072ab39'
        response.each { |k,v| conference.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real conference' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        conference = Twilio::Conference.find 'phony'
        conference.should be_nil
      end
    end
  end

  describe '#participants' do
    before do
      stub_api_call 'list_conferences'
      stub_request(:get, resource_uri + '/CFbbe46ff1274e283f7e3ac1df0072ab39/Participants.json').
        to_return :body => canned_response('list_participants'), :status => 200
    end

    let(:resp) { Twilio::Conference.all.first.participants }

    it 'returns a collection of participants' do
      resp.should_not be_empty
      resp.all? { |r| r.is_a? Twilio::Participant }.should be_true
    end

    it 'returns a collection containing objects with attributes corresponding to the response' do
      participants = JSON.parse(canned_response('list_participants').read)['participants']

      participants.each_with_index do |obj,i|
        obj.each do |attr, value| 
          resp[i].send(attr).should == value
        end
      end
    end
    
    it 'returns a collection with a length corresponding to the API response' do
      resp.length.should == 1
    end
  end

end
