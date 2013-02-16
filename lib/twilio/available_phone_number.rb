module Twilio
  class AvailablePhoneNumber
    include Twilio::Resource 
    extend  Twilio::Finder

    class << self
      def all(opts={})
        opts                     = Hash[opts.map { |k,v| [k.to_s.camelize, v]}]
        country_code             = opts['IsoCountryCode'] ? opts.delete('IsoCountryCode') : 'US'
        number_type              = opts.delete('TollFree') ? 'TollFree' : 'Local'
        params                   = { :query => opts } if opts.any?

        handle_response get "/Accounts/#{Twilio::Config.account_sid}/AvailablePhoneNumbers/#{country_code}/#{number_type}.json", params 
      end

      private :new
      undef_method :count

    end

    # Shortcut for creating a new incoming phone number. Delegates to Twilio::IncomingPhoneNumber.create accepting the same options as that method does.
    def purchase!(opts={})
      Twilio::IncomingPhoneNumber.create opts.update :phone_number => phone_number
    end
  end
end
