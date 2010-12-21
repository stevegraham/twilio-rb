module Twilio
  class IncomingPhoneNumber
    extend Twilio::Finder
    include Twilio::Resource
    include Twilio::Persistable
  end
end
