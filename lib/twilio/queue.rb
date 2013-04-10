module Twilio
  class Queue
    extend Twilio::Finder
    include Twilio::Resource
    include Twilio::Persistable
    include Twilio::Deletable

    mutable_attributes :sid, :friendly_name, :current_size, :max_size, :average_wait_time

  end
end
