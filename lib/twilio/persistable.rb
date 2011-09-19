module Twilio
  module Persistable

    def self.included(base)
      base.instance_eval do
        def create(attrs={})
          attrs       = attrs.with_indifferent_access
          # Support subaccounts by optionally passing in an account_sid or account object
          account_sid = attrs.delete('account_sid') || attrs.delete('account').try(:sid) || Twilio::ACCOUNT_SID

          res = post "#{resource_path(account_sid)}.json", :body => Hash[attrs.map { |k,v| [k.to_s.camelize, v]}]

          if (400..599).include? res.code
            raise Twilio::APIError.new "Error ##{res.parsed_response['code']}: #{res.parsed_response['message']}"
          else
            res.parsed_response['api_version'] = res.parsed_response['api_version'].to_s
            new res.parsed_response
          end
        end

        private
        def resource_path(account_sid)
          "/Accounts/#{account_sid}/#{resource_name}"
        end

        def resource_name
          name.demodulize.pluralize
        end
      end
    end
  end
end
