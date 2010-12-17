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
        new Hash[hash.map { |k,v| [k.camelize, v] }] 
      end
    end 

    def all(opts={})
      opts                = Hash[opts.map { |k,v| [k.to_s.camelize, v]}]
      params              = { :query => opts } if opts.any?

      handle_response get "/Accounts/#{Twilio::ACCOUNT_SID}/#{name.demodulize + 's'}.json", params
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
