module Twilio
  class AvailablePhoneNumber
    include Twilio::Resource 

    class << self
      def all(opts={})
        opts                     = Hash[opts.map { |k,v| [k.to_s.camelize, v]}]
        country_code             = opts['IsoCountryCode'] ? opts.delete('IsoCountryCode') : 'US'
        number_type              = opts.delete('TollFree') ? 'TollFree' : 'Local'
        params                   = { :query => opts } if opts.any?

        handle_response get "/Accounts/#{Twilio::ACCOUNT_SID}/AvailablePhoneNumbers/#{country_code}/#{number_type}.json", params 
      end

      alias   find all
      private :new

      private
      def handle_response(res) # :nodoc:
        if (400..599).include? res.code
          raise Twilio::APIError.new "Error ##{res.parsed_response['code']}: #{res.parsed_response['message']}"
        else
          res.parsed_response[name.demodulize.underscore + 's'].map { |p| new p }
        end
      end

    end
  end
end
