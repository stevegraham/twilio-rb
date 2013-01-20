require 'base64'
require 'openssl'
require 'digest/sha1'

module Twilio
  module RequestFilter
    def filter(controller)
      request = controller.request
      if request.format.try(:voice?)
        controller.head(:forbidden) unless authorised?(request)
      end
    end

    private

    def authorised? request
      return true if development?

      expected_signature_for(request) == (request.env['HTTP_X_TWILIO_SIGNATURE'] || request.env['X-Twilio-Signature'])
    end

    def development?
      if const_defined? "Rails"
        Rails.env.development?
      elsif ENV["RACK_ENV"] == "development"
        true
      else
        false
      end
    rescue
      false
    end

    def expected_signature_for(request)
      string_to_sign = request.url + request.request_parameters.sort.join
      digest         = OpenSSL::Digest::Digest.new('sha1')
      hash           = OpenSSL::HMAC.digest(digest, Twilio::AUTH_TOKEN, string_to_sign)

      Base64.encode64(hash).strip
    end

    extend self
  end
end
