module Twilio
  class OutgoingCallerId
    include Twilio::Resource
    include Twilio::Deletable
    include Twilio::Persistable
    extend Twilio::Finder

    def friendly_name=(value)
      update_attributes :friendly_name => value
    end
  end
end
