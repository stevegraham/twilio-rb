module Twilio
  class Participant
    include Twilio::Resource
    include Twilio::Deletable

    mutable_attributes :muted

    alias kick! destroy

    def mute!
      state_guard do
        update_attributes muted? ? { :muted => false } : { :muted => true }
      end
    end

    def muted?
      muted
    end

    private

    def path
      "/Accounts/#{account_sid}/Conferences/#{conference_sid}/Participants/#{call_sid}.json"
    end
  end
end
