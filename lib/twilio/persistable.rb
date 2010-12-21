module Twilio
  module Persistable

    def self.included(base)
      base.class_eval do
        class << base
          def create(attrs={})
            # All Twilio resources follow a convention, except SMS :(
            resource = name.demodulize
            resource = name == 'Twilio::SMS' ? "SMS/Messages" : resource + 's'
            res = post "/Accounts/#{Twilio::ACCOUNT_SID}/#{resource}.json", :body => Hash[attrs.map { |k,v| [k.to_s.camelize, v]}]
            if (400..599).include? res.code
              raise Twilio::APIError.new "Error ##{res.parsed_response['code']}: #{res.parsed_response['message']}"
            else
              res.parsed_response['api_version'] = res.parsed_response['api_version'].to_s
              new res.parsed_response
            end
          end
        end
      end
    end

  end
end
