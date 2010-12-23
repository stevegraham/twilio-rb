module Twilio
  module Deletable
    def destroy
      state_guard { freeze && true if self.class.delete path }
    end
  end
end
