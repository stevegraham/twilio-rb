module Twilio
  module Account
    include Twilio::Resource
    @attributes = {}

    def attributes
      @attributes.empty? ? reload! : @attributes
    end

    def reload!
      handle_response get "/Accounts/#{Twilio::ACCOUNT_SID}.json"
    end

    def friendly_name=(name)
      handle_response put "/Accounts/#{Twilio::ACCOUNT_SID}.json", :body => { :friendly_name => name }
    end

    extend self
  end
end