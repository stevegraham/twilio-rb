require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

def parse_scope(scope)
  scope.scan(/scope:(client|stream):(incoming|outgoing)\?(\S+)/).map do |service, privilege, query|
    [service, privilege, CGI.parse(query)]
  end.flatten
end

describe 'Twilio::CapabilityToken' do
  before { Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') } }

  describe '.create' do
    it 'sets iss in payload' do
      token = Twilio::CapabilityToken.create \
        :allow_incoming => 'client_identifier',
        :allow_outgoing => 'APXXXXXXXXXXXXXXXXXXXXX'

      decoded = JWT.decode token, Twilio::AUTH_TOKEN
      decoded['iss'].should == Twilio::ACCOUNT_SID
    end

    context 'when no specified expiry time is given' do
      Timecop.freeze do
        it 'sets ttl as 1 hour from current time' do
          token = Twilio::CapabilityToken.create \
            :allow_incoming => 'client_identifier',
            :allow_outgoing => 'APXXXXXXXXXXXXXXXXXXXXX'

          decoded = JWT.decode token, Twilio::AUTH_TOKEN
          decoded['exp'].should == 1.hour.from_now.to_i
        end
      end
    end

    context 'when an expiry time is explicitly passed' do
      it 'sets ttl as given time' do
        Timecop.freeze do
          token = Twilio::CapabilityToken.create \
            :allow_incoming => 'client_identifier',
            :allow_outgoing => 'APXXXXXXXXXXXXXXXXXXXXX',
            :expires        => 4.hours.from_now

          decoded = JWT.decode token, Twilio::AUTH_TOKEN
          decoded['exp'].should == 4.hours.from_now.to_i
        end
      end
    end

    it 'sets up the correct scopes' do
      token = Twilio::CapabilityToken.create \
        :allow_incoming => 'client_identifier',
        :allow_outgoing => ['APXXXXXXXXXXXXXXXXXXXXX', { :app_param => 'foo' }]
      scopes = JWT.decode(token, Twilio::AUTH_TOKEN)['scope'].split
      scopes.one? do |scope|
        parse_scope(scope) == ["client", "incoming", {"clientName"=>["client_identifier"]}]
      end.should be_true

      # client outgoing scope should know about client name if there is an incoming capability
      scopes.one? do |scope|
        parse_scope(scope) == ["client", "outgoing", {"appSid"=>["APXXXXXXXXXXXXXXXXXXXXX"], "appParams"=>["app_param=foo"], "clientName"=>["client_identifier"]}]
      end.should be_true
    end
  end
end
