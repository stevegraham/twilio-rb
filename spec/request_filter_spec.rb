require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Twilio::RequestFilter' do
  before { Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '1c892n40nd03kdnc0112slzkl3091j20' }
  let(:request_parameters) do
    {:request_parameters => {
      'ApiVersion'    => '2010-04-01',
      'AccountSid'    => 'AC9a9f9392lad99kla0sklakjs90j092j3',
      'CallSid'       => 'CAd800bb12c0426a7ea4230e492fef2a4f',
      'CallStatus'    => 'ringing',
      'Called'        => '+15306384866',
      'CalledCity'    => 'OAKLAND',
      'CalledCountry' => 'US',
      'CalledState'   => 'CA',
      'CalledZip'     => '94612',
      'Caller'        => '+15306666666',
      'CallerCity'    => 'SOUTH LAKE TAHOE',
      'CallerCountry' => 'US',
      'CallerName'    => 'CA Wireless Call',
      'CallerState'   => 'CA',
      'CallerZip'     => '89449',
      'Direction'     => 'inbound',
      'From'          => '+15306666666',
      'FromCity'      => 'SOUTH LAKE TAHOE',
      'FromCountry'   => 'US',
      'FromState'     => 'CA',
      'FromZip'       => '89449',
      'To'            => '+15306384866',
      'ToCity'        => 'OAKLAND',
      'ToCountry'     => 'US',
      'ToState'       => 'CA',
      'ToZip'         => '94612' },
      :env    => {
        'X-Twilio-Signature'      => 'fF+xx6dTinOaCdZ0aIeNkHr/ZAA=',
        'HTTP_X_TWILIO_SIGNATURE' => 'fF+xx6dTinOaCdZ0aIeNkHr/ZAA=' },
        :format                   => mock(:voice? => true),
        :url                      => 'http://www.postbin.org/1ed898x'
    }
  end

  describe '.filter' do
    context "in development mode" do
      before do
        ENV["RACK_ENV"] = "development"
      end

      after do
        ENV["RACK_ENV"] = "test"
      end

      it 'does not trigger a 401 response' do
        request_parameters[:env]['X-Twilio-Signature']= nil
        request_parameters[:env]['HTTP_X_TWILIO_SIGNATURE']= nil

        controller = stub :request => stub(request_parameters)

        controller.expects(:head).with(:forbidden).never
        Twilio::RequestFilter.filter(controller)
      end
    end

    context 'when request signatures do match' do
      it 'does not trigger a 401 response' do
        request = stub request_parameters

        controller = stub :request => request

        controller.expects(:head).with(:forbidden).never
        Twilio::RequestFilter.filter(controller)
      end
    end

    context 'when request signatures do not match' do
      it 'returns 401 response' do
        params = request_parameters
        params[:env] = {
          'X-Twilio-Signature'      => nil,
          'HTTP_X_TWILIO_SIGNATURE' => nil
        }

        request = stub params
        controller = stub :request => request

        controller.expects(:head).with(:forbidden)
        Twilio::RequestFilter.filter(controller)
      end
    end
  end
end
