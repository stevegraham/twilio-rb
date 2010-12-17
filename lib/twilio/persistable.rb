module Twilio
  module Persistable

    def self.included(base)
      base.class_eval do
        def save
          # All Twilio resources follow a convention, except SMS :(
          resource = self.class.name.demodulize
          resource = self.class.name == 'Twilio::SMS' ? "SMS/Messages" : resource + 's'
          handle_response self.class.post "/Accounts/#{Twilio::ACCOUNT_SID}/#{resource}.json", :body => attributes
        end
      end
      class << base
        def create(attrs={})
          new(attrs).tap &:save
        end
      end
    end

  end
end
