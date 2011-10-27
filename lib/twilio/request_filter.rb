require 'base64'
require 'openssl'
require 'digest/sha1'

module Twilio
  module RequestFilter
    def filter(controller)
      request = controller.request
      format  = request.format

      if format && format.voice? && request.ssl?
        controller.head(:forbidden) if expected_signature_for(request) != request.env['X-Twilio-Signature']
      end
    end

    private
    def expected_signature_for(request)
      string_to_sign = request.url + request.params.sort.join
      digest         = OpenSSL::Digest::Digest.new 'sha1'
      hash           = OpenSSL::HMAC.digest digest, Twilio::AUTH_TOKEN, string_to_sign

      Base64.encode64(hash).strip
    end

    extend self
  end
end