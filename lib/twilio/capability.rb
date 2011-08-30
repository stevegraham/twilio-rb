module Twilio
  module CapabilityToken
    def create(opts={})
      opts.stringify_keys!
      account_sid, auth_token = *credentials_for(opts)
      payload = {
        :exp   => (opts.delete('expires') || 1.hour.from_now).to_i,
        :scope => opts.map { |k,v| send k, v, opts }.join(' '),
        :iss   => account_sid
      }
      JWT.encode payload, auth_token
    end

    private

    def credentials_for(opts)
      if opts['account_sid'] && opts['auth_token']
        [opts.delete('account_sid'), opts.delete('auth_token')]
      else
        [Twilio::ACCOUNT_SID, Twilio::AUTH_TOKEN]
      end
    end

    def allow_incoming(client_id, opts)
      token_for 'client', 'incoming', { 'clientName' => client_id }
    end

    def allow_outgoing(payload, opts)
      p = {}
      if payload.respond_to? :each
        p['appSid']    = payload.shift
        p['appParams'] = uri_encode payload.pop
      else # it's a string
        p['appSid'] = payload
      end
      p['clientName'] = opts['allow_incoming'] if opts['allow_incoming']
      token_for 'client', 'outgoing', p
    end

    def uri_encode(hash)
      hash.map { |k,v| "#{CGI.escape k.to_s}=#{CGI.escape v}" }.join '&'
    end

    def token_for(service, privilege, params = {})
      token = "scope:#{service}:#{privilege}"
      token << "?#{uri_encode params}" if params.any?
    end

    extend self
  end
end
