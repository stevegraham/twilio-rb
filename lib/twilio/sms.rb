module Twilio
  class SMS
    include Twilio::Resource
    include Twilio::Persistable
    extend  Twilio::Finder
  end
end
