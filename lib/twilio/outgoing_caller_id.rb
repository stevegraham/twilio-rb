module Twilio
  class OutgoingCallerId
    include Twilio::Resource
    include Twilio::Deletable
    include Twilio::Persistable
    extend Twilio::Finder

    mutable_attributes :friendly_name
  end
end
