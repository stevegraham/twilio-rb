module Twilio
  module Finder
    def find(id)
      # All Twilio resources follow a convention, except SMS :(
      klass_name          = name.demodulize
      resource            = klass_name == 'SMS' ? "#{klass_name}/Messages" : klass_name.pluralize
      res                 = get "/Accounts/#{Twilio::ACCOUNT_SID}/#{resource}/#{id}.json"
      hash                = res.parsed_response
      if (200..299).include? res.code
        hash['api_version'] = hash['api_version'].to_s # api_version parsed as a date by http_party
        new hash 
      end
    end 

    def all(opts={})
      opts = opts.map do |k,v|
        if [:updated_before, :created_before, :updated_after, :created_after].include? k
          k = k.to_s
          # Fancy schmancy-ness to handle Twilio <= URI operator for dates
          comparator = k =~ /before$/ ? '<=' : '>='
          "Date" << k.gsub(/\_\w+$/, '').capitalize << comparator << v.to_s
        else
          "#{k.to_s.camelize}=#{v}"
        end
      end

      params = "?#{URI.encode(opts.join '&')}" unless opts.empty?
      # TODO: This won't work with SMS messages, see above. Perhaps handle SMS case by overriding in
      # SMS class itself instead of polluting generic functionality
      handle_response get "/Accounts/#{Twilio::ACCOUNT_SID}/#{name.demodulize + 's'}.json#{params}"
    end

    private
    def handle_response(res) # :nodoc:
      if (400..599).include? res.code
        raise Twilio::APIError.new "Error ##{res.parsed_response['code']}: #{res.parsed_response['message']}"
      else
        res.parsed_response[name.demodulize.underscore + 's'].map do |p|
          p['api_version'] = p['api_version'].to_s # api_version parsed as a date by http_party
          new p
        end
      end
    end

  end
end
