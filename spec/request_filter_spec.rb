require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Twilio::RequestFilter' do
  before { Twilio::Config.setup :account_sid => 'AC000000000000', :auth_token => '1c892n40nd03kdnc0112slzkl3091j20' }

  let(:controller) { double request: request }
  let(:request)    { double params }

  let(:params) do
    { request_parameters: {
      'AccountSid' => 'AC9a9f9392lad99kla0sklakjs90j092j3', 'ApiVersion' => '2010-04-01',
      'CallSid' => 'CAd800bb12c0426a7ea4230e492fef2a4f', 'CallStatus' => 'ringing',
      'Called' => '+15306384866', 'CalledCity' => 'OAKLAND', 'CalledCountry' => 'US',
      'CalledState' => 'CA', 'CalledZip' => '94612', 'Caller' => '+15306666666',
      'CallerCity' => 'SOUTH LAKE TAHOE', 'CallerCountry' => 'US',
      'CallerName' => 'CA Wireless Call', 'CallerState' => 'CA',
      'CallerZip' => '89449', 'Direction' => 'inbound', 'From' => '+15306666666',
      'FromCity' => 'SOUTH LAKE TAHOE', 'FromCountry' => 'US', 'FromState' => 'CA',
      'FromZip' => '89449', 'To' => '+15306384866', 'ToCity' => 'OAKLAND',
      'ToCountry' => 'US', 'ToState' => 'CA', 'ToZip' => '94612' },
    env: {
      'X-Twilio-Signature' => 'fF+xx6dTinOaCdZ0aIeNkHr/ZAA=',
      'HTTP_X_TWILIO_SIGNATURE' => 'fF+xx6dTinOaCdZ0aIeNkHr/ZAA=' },
    format: double(:voice? => true),
    url: 'http://www.postbin.org/1ed898x' }
  end

  [:filter, :before].each do |method_name|
    describe ".#{method_name}" do
      context 'when request signatures do match' do
        it 'does not trigger a 401 response' do
          expect(controller).not_to receive(:head).with(:forbidden)
          Twilio::RequestFilter.send(method_name, controller)
        end
      end

      context 'when request signatures do not match' do
        before { params.update env: {}  }
        it 'returns 401 response' do
          expect(controller).to receive(:head).with(:forbidden)
          Twilio::RequestFilter.send(method_name, controller)
        end
      end
    end
  end
end
