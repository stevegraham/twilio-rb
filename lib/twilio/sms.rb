module Twilio
  class SMS
    include Twilio::Resource

    # Sends the SMS message
    def save
      handle_response self.class.post "/Accounts/#{Twilio::ACCOUNT_SID}/SMS/Messages.json", :body => attributes
    end
  end
end