module Twilio
  class Application
    extend Twilio::Finder
    include Twilio::Resource
    include Twilio::Persistable
    include Twilio::Deletable

    mutable_attributes :friendly_name, :api_version, :voice_url, :voice_method, :voice_fallback_url,
      :voice_fallback_method, :status_callback, :status_callback_method, :sms_url, :sms_method,
      :sms_fallback_url, :sms_fallback_method

  end
end

