require 'spec_helper'

describe Twilio::AvailablePhoneNumber do

  let(:resource_uri) { "https://#{Twilio::Config.account_sid}:#{Twilio::Config.auth_token}@api.twilio.com/2010-04-01/Accounts/#{Twilio::Config.account_sid}/AvailablePhoneNumbers" }
  before { Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '79ad98413d911947f0ba369d295ae7a3' }

  def stub_api_call(uri_tail, response_file)
    stub_request(:get, resource_uri + uri_tail).
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    context 'for US local numbers' do
      before { stub_api_call '/US/Local.json?AreaCode=510&Page=2', 'available_local_phone_numbers' }
      let(:resp) { Twilio::AvailablePhoneNumber.all :page => 2, :area_code => '510' }

      it 'returns a collection of objects with a length corresponding to the response' do
        resp = Twilio::AvailablePhoneNumber.all :page => 2, :area_code => '510'
        resp.length.should == 2
      end

      it 'returns a collection containing instances of Twilio::AvailablePhoneNumber' do
        resp = Twilio::AvailablePhoneNumber.all :page => 2, :area_code => '510'
        resp.all? { |r| r.is_a? Twilio::AvailablePhoneNumber }.should be true
      end

      JSON.parse(canned_response('available_local_phone_numbers'))['available_phone_numbers'].each_with_index do |obj,i|
        obj.each { |attr, value| specify { resp[i].send(attr).should == value } }
      end
    end

    context 'for non-US local numbers' do
      before { stub_api_call '/CA/Local.json', 'available_local_phone_numbers' }
      it 'makes a request for a non-US number as per the country code' do
        Twilio::AvailablePhoneNumber.all :iso_country_code => 'CA'
        a_request(:get, resource_uri + '/CA/Local.json').should have_been_made
      end
    end

    context 'for US toll free numbers' do
      before { stub_api_call '/US/TollFree.json?Contains=STORM', 'available_toll_free_phone_numbers' }

      it 'returns a collection of objects with a length corresponding to the response' do
        resp = Twilio::AvailablePhoneNumber.all :toll_free => true, :contains => 'STORM'
        resp.length.should == 1
      end

      its 'collection contains instances of Twilio::AvailablePhoneNumber' do
        resp = Twilio::AvailablePhoneNumber.all :toll_free => true, :contains => 'STORM'
        resp.all? { |r| r.is_a? Twilio::AvailablePhoneNumber }.should be true
      end

      its 'collection contains objects whose attributes correspond to the response' do
        numbers = JSON.parse(canned_response('available_toll_free_phone_numbers'))['available_phone_numbers']
        resp    = Twilio::AvailablePhoneNumber.all :toll_free => true, :contains => 'STORM'

        numbers.each_with_index do |obj,i|
          obj.each { |attr, value| resp[i].send(attr).should == value }
        end
      end
    end
  end

  describe '#purchase!' do
    let(:available_number) { Twilio::AvailablePhoneNumber.new phone_number: '+12125550000' }

    it "delegates to Twilio::IncomingPhoneNumber.create merging self.phone_number with any given args" do
      expect(Twilio::IncomingPhoneNumber).to receive(:create).with phone_number: '+12125550000',
        voice_url: 'http://www.example.com/twiml.xml', voice_method: 'post'

      available_number.purchase! :voice_url => 'http://www.example.com/twiml.xml', :voice_method => 'post'
    end
  end
end
