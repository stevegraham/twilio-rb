module Twilio
  module Deletable
    def destroy
      account_sid = self[:account_sid] if self[:connect_app_sid]
      state_guard { freeze && true if self.class.delete path, :account_sid => account_sid }
    end
  end
end
