module Twilio
  module Deletable
    def destroy
      state_guard { freeze && true if self.class.delete path }
    end
    
    private
    def path
      "/Accounts/#{Twilio::ACCOUNT_SID}/#{self.class.name.demodulize + 's'}/#{self[:sid]}.json"
    end

    def state_guard
      if frozen?
        raise RuntimeError, "#{self.class.name.demodulize} has already been destroyed"
      else
        yield
      end
    end
  end
end
