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

    %w<friendly_name api_version sms_url sms_method sms_fallback_url sms_fallback_method>.each do |meth|
      define_method "#{meth}=" do |arg|
        update_attributes meth => arg
      end
    end

    private
    def resource_name
      "SMS/ShortCodes"
    end

  end
end
