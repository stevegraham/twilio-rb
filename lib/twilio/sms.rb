module Twilio
  class SMS
    include Twilio::Resource

    def initialize(attrs ={})  #:nodoc:
      @attributes = Hash[attrs.map { |k,v| [k.to_s.camelize, v.to_s] }]
    end

    # Sends the SMS message
    def save
      handle_response self.class.post "/Accounts/#{Twilio::ACCOUNT_SID}/SMS/Messages.json", :body => attributes
    end
  end
end