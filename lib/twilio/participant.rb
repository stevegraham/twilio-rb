module Twilio
  class Participant
    include Twilio::Resource

    def kick!
      state_guard { freeze && true if self.class.delete path }
    end

    def mute!
      state_guard do
        if muted?
          handle_response self.class.post path, :body => 'Muted=false'
        else
          handle_response self.class.post path, :body => 'Muted=true'
        end
      end
    end

    def muted?
      muted
    end

    private

    def state_guard
      if frozen?
        raise RuntimeError, 'Participant has already been removed from conference'
      else
        yield
      end
    end

    def path
      "/Accounts/#{Twilio::ACCOUNT_SID}/Conferences/#{conference_sid}/Participants/#{call_sid}.json"
    end
  end
end