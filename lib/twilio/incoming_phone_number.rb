module Twilio
  class IncomingPhoneNumber
    extend Twilio::Finder
    include Twilio::Resource
    include Twilio::Persistable
    include Twilio::Deletable

    %w<friendly_name api_version voice_url voice_method voice_fallback_url voice_fallback_method status_callback status_callback_method sms_url sms_method sms_fallback_url sms_fallback_method voice_caller_id_lookup>.each do |meth|
      define_method "#{meth}=" do |arg|
        update_attributes meth => arg 
      end
    end
  end
end
