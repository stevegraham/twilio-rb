module Twilio
  class ShortCode
    include Twilio::Resource
    extend Twilio::Finder

    class << self
      private

      def resource_name
        "SMS/ShortCodes"
      end
    end

    mutable_attributes :friendly_name, :api_version, :sms_url, :sms_method,
      :sms_fallback_url, :sms_fallback_method

    private
    def resource_name
      "SMS/ShortCodes"
    end

  end
end
